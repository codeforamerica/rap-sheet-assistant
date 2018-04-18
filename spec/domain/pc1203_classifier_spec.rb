require 'spec_helper'

require_relative '../../app/domain/pc1203_classifier'

describe PC1203Classifier do
  let(:user) { FactoryBot.build(:user) }
  let(:all_events) {}
  let(:conviction_event) { build_conviction_event(sentence: sentence) }

  subject { described_class.new(user: user, event: conviction_event, event_collection: all_events) }

  describe '#potentially_eligible?' do
    context "when the conviction's sentence had prison" do
      let(:sentence) { ConvictionSentence.new(prison: 1.year) }

      it 'returns false' do
        expect(subject).not_to be_potentially_eligible
      end
    end

    context "when the conviction's sentence did not include prison" do
      let(:sentence) { ConvictionSentence.new(prison: nil) }

      it 'returns true' do
        expect(subject).to be_potentially_eligible
      end
    end
  end

  describe '#eligible?' do
    let(:sentence) { ConvictionSentence.new(prison: nil) }
    let(:user) do
      FactoryBot.build(
        :user,
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

    context 'when the user is on probation' do
      before do
        user.on_probation = true
      end

      xcontext 'and they have not yet finished 1/2 of their probation' do
        before do
          user.finished_half_of_probation = false
        end

        it 'returns false' do
          expect(subject).not_to be_eligible
        end
      end

      xcontext 'and they have finished 1/2 of their probation' do
        before do
          user.finished_half_of_probation = true
        end

        it 'returns true' do
          expect(subject).to be_eligible
        end
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
        let(:conviction_event) do
          build_conviction_event(
            sentence: ConvictionSentence.new(probation: 5.months),
            date: Date.new(1991, 5, 1)
          )
        end
        let(:all_events) { EventCollection.new([conviction_event]) }

        it 'returns successful completion' do
          expect(subject.remedy).to eq ({
            code: '1203.4',
            scenario: :successful_completion
          })
        end
      end

      # context 'probation terminated early' do
      #   let(:all_events) { [conviction_event] }
      #
      #   it 'returns early termination' do
      #     expect(subject.remedy).to eq ({
      #       code: '1203.4',
      #       scenario: :early_termination
      #     })
      #   end
      # end

      context 'probation violated' do
        let(:conviction_event) do
          build_conviction_event(
            sentence: ConvictionSentence.new(probation: 5.months),
            date: Date.new(1991, 5, 1)
          )
        end
        let(:arrest_event) { ArrestEvent.new(date: Date.new(1991, 7, 1)) }
        let(:all_events) { EventCollection.new([conviction_event, arrest_event]) }

        it 'returns discretionary' do
          expect(subject.remedy).to eq ({
            code: '1203.4',
            scenario: :discretionary
          })
        end
      end

      context 'unknown probation completion status' do
        let(:conviction_event) do
          build_conviction_event(
            sentence: ConvictionSentence.new(probation: 5.months),
            date: nil
          )
        end
        let(:all_events) { EventCollection.new([conviction_event]) }

        it 'returns discretionary' do
          expect(subject.remedy).to eq ({
            code: '1203.4',
            scenario: :unknown
          })
        end
      end
    end

    context 'sentence does not include probation' do
      let(:conviction_event) do
        build_conviction_event(
          sentence: ConvictionSentence.new(probation: nil),
          date: Date.new(1991, 5, 1),
          counts: [build_conviction_count(severity: severity)]
        )
      end

      context 'when the event severity is misdemeanor' do
        let(:severity) { 'M' }

        context 'when rap sheet is clear for a year after sentencing' do
          let(:arrest_event) { ArrestEvent.new(date: Date.new(1992, 7, 1)) }
          let(:all_events) { EventCollection.new([conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy).to eq({
              code: '1203.4a',
              scenario: :successful_completion
            })
          end
        end

        context 'when rap sheet has event within a year after sentencing' do
          let(:arrest_event) { ArrestEvent.new(date: Date.new(1992, 4, 1)) }
          let(:all_events) { EventCollection.new([conviction_event, arrest_event]) }

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
          let(:arrest_event) { ArrestEvent.new(date: Date.new(1992, 7, 1)) }
          let(:all_events) { EventCollection.new([conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy).to eq({
              code: '1203.4a',
              scenario: :successful_completion
            })
          end
        end

        context 'when rap sheet has event within a year after sentencing' do
          let(:arrest_event) { ArrestEvent.new(date: Date.new(1992, 4, 1)) }
          let(:all_events) { EventCollection.new([conviction_event, arrest_event]) }

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

  def build_conviction_event(date: nil, case_number: nil, courthouse: nil, sentence: nil, counts: counts)
    event = ConvictionEvent.new(
      date: date,
      case_number: case_number,
      courthouse: courthouse,
      sentence: sentence
    )
    event.counts = counts

    event
  end

  def build_conviction_count(code: nil, section: nil, severity: nil)
    ConvictionCount.new(
      event: nil,
      code_section_description: nil,
      severity: severity,
      code: code,
      section: section
    )
  end
end
