require 'spec_helper'

require_relative '../../app/domain/pc1203_classifier'

describe PC1203Classifier do
  let(:user) { build(:user) }
  let(:rap_sheet) {}
  let(:count) { build_count(disposition: build_disposition(sentence: sentence)) }
  let(:conviction_event) { build_court_event(counts: [count], date: date) }
  let(:date) { Date.today - 5.years }

  subject { described_class.new(user: user, event: conviction_event, rap_sheet: rap_sheet) }

  describe '#potentially_eligible?' do
    context "when the conviction's sentence had prison" do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: 1.year) }

      it 'returns false' do
        expect(subject).not_to be_potentially_eligible
      end
    end

    context "when the conviction's sentence did not include prison" do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: nil) }

      it 'returns true' do
        expect(subject).to be_potentially_eligible
      end
    end

    context 'when the conviction is less than a year old' do
      let(:date) { Date.today - 6.months }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: nil) }

      it 'returns false' do
        expect(subject).not_to be_potentially_eligible
      end
    end
    context 'when the conviction has no date' do
      let(:date) { nil }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: nil) }

      it 'returns false' do
        expect(subject).not_to be_potentially_eligible
      end
    end
  end

  describe '#eligible?' do
    let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: nil) }
    let(:user) do
      build(:user,
        on_parole: false,
        on_probation: false,
        outstanding_warrant: false,
        owe_fees: false
      )
    end

    context 'when the user is in good standing' do
      it 'returns true' do
        expect(subject).to be_eligible
      end
    end

    context 'when the user is on parole' do
      before do
        user.on_parole = true
      end

      it 'returns false' do
        expect(subject).not_to be_eligible
      end
    end

    context 'when the user has a warrant' do
      before do
        user.outstanding_warrant = true
      end

      it 'returns false' do
        expect(subject).not_to be_eligible
      end
    end
  end

  describe '#remedy' do
    context 'sentence includes probation' do
      context 'probation successfully completed' do
        let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 5.months) }
        let(:conviction_event) do
          build_court_event(
            counts: [count],
            date: Date.new(1991, 5, 1)
          )
        end
        let(:rap_sheet) { build_rap_sheet(events: [conviction_event]) }

        it 'returns successful completion' do
          expect(subject.remedy).to eq ({
            code: '1203.4',
            scenario: :successful_completion
          })
        end
      end

      context 'probation violated' do
        let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 5.months) }
        let(:conviction_event) do
          build_court_event(
            counts: [count],
            date: Date.new(1991, 5, 1)
          )
        end
        let(:arrest_event) { build_other_event(event_type: 'arrest', date: Date.new(1991, 7, 1)) }
        let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

        it 'returns discretionary' do
          expect(subject.remedy).to eq ({
            code: '1203.4',
            scenario: :discretionary
          })
        end
      end

      context 'unknown probation completion status' do
        let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 5.months) }
        let(:conviction_event) do
          build_court_event(
            counts: [count],
            date: nil
          )
        end
        let(:rap_sheet) { build_rap_sheet(events: [conviction_event]) }

        it 'returns discretionary' do
          expect(subject.remedy).to eq ({
            code: '1203.4',
            scenario: :unknown
          })
        end
      end
    end

    context 'sentence does not include probation' do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: nil) }
      let(:conviction_event) do
        build_court_event(
          date: Date.new(1991, 5, 1),
          counts: [build_count(disposition: build_disposition(severity: severity, sentence: sentence))]
        )
      end

      let(:arrest_event) { build_other_event(event_type: 'arrest', date: arrest_date) }

      context 'when the event severity is misdemeanor' do
        let(:severity) { 'M' }

        context 'when rap sheet is clear for a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 7, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy).to eq({
              code: '1203.4a',
              scenario: :successful_completion
            })
          end
        end

        context 'when rap sheet has event within a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 4, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy).to eq({
              code: '1203.4a',
              scenario: :discretionary
            })
          end
        end
      end

      context 'when the event severity is infraction' do
        let(:severity) { 'I' }

        context 'when rap sheet is clear for a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 7, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy).to eq({
              code: '1203.4a',
              scenario: :successful_completion
            })
          end
        end

        context 'when rap sheet has event within a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 4, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy).to eq({
              code: '1203.4a',
              scenario: :discretionary
            })
          end
        end
      end

      context 'when the event severity is felony' do
        let(:severity) { 'F' }

        it 'returns 1203.41' do
          expect(subject.remedy[:code]).to eq '1203.41'
        end
      end

      context 'unknown severity' do
        let(:severity) { nil }

        it 'returns nil' do
          expect(subject.remedy).to eq nil
        end
      end
    end
  end
end
