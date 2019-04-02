require 'rails_helper'

require_relative '../../app/domain/pc1203_classifier'

describe PC1203Classifier do
  let(:rap_sheet) { build_rap_sheet(events: [conviction_event]) }

  subject { described_class.new(event: conviction_event, rap_sheet: rap_sheet) }

  describe '#eligible?' do
    let(:conviction_event) do
      build_court_event(
        date: date,
        counts: [build_count(dispositions: [build_disposition(severity: severity, sentence: sentence)])]
      )
    end

    context 'probation sentences' do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 1.year, probation: 1.year) }
      let(:severity) { 'F' }

      context 'when sentence is not yet completed' do
        let(:date) { Date.today - 8.months }

        it 'returns false' do
          expect(subject.eligible?).to be false
        end
      end

      context 'when sentence is completed' do
        let(:date) { Date.today - 3.years }

        it 'returns true' do
          expect(subject.eligible?).to be true
        end
      end
    end

    context 'non-probation misdemeanors' do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 6.months, probation: nil) }
      let(:severity) { 'M' }
      context 'when it is less than a year from the conviction date' do
        let(:date) { Date.today - 8.months }
        it 'returns false' do
          expect(subject.eligible?).to be false
        end
      end

      context 'when it is more than a year from the conviction date' do
        let(:date) { Date.today - 13.months }
        it 'returns true' do
          expect(subject.eligible?).to be true
        end
      end
    end

    context 'non-probation infractions' do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 6.months, probation: nil) }
      let(:severity) { 'I' }
      context 'when it is less than a year from the conviction date' do
        let(:date) { Date.today - 8.months }
        it 'returns false' do
          expect(subject.eligible?).to be false
        end
      end

      context 'when it is more than a year from the conviction date' do
        let(:date) { Date.today - 13.months }
        it 'returns true' do
          expect(subject.eligible?).to be true
        end
      end
    end

    context 'non-probation felonies' do
      let(:severity) { 'F' }
      context 'when it has a prison sentence' do
        let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: 6.months, probation: nil) }
        let(:date) { Date.today - 5.years }
        it 'returns false' do
          expect(subject.eligible?).to be false
        end
      end

      context 'when it has no prison and is less than two years from the end of sentence' do
        let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 1.year, probation: nil) }
        let(:date) { Date.today - 25.months }
        it 'returns false' do
          expect(subject.eligible?).to be false
        end
      end

      context 'when it has no prison and is more than two years from the end of sentence' do
        let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 1.year, probation: nil) }
        let(:date) { Date.today - 4.years }
        it 'returns true' do
          expect(subject.eligible?).to be true
        end
      end
    end

    context 'when the conviction has no date' do
      let(:date) { nil }
      let(:severity) { 'F' }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: nil) }

      it 'returns false' do
        expect(subject.eligible?).to be false
      end
    end

    context 'when the conviction has no severity' do
      let(:date) { Date.today - 5.years }
      let(:severity) { nil }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: nil) }

      it 'returns false' do
        expect(subject.eligible?).to be false
      end
    end
  end

  describe '#remedy_details and #discretionary?' do
    let(:date) { Date.new(1991, 5, 1)}
    context 'sentence includes probation' do
      let(:count) { build_count(dispositions: [build_disposition(sentence: sentence, date: date)]) }

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
          expect(subject.remedy_details).to eq ({
            code: '1203.4',
            scenario: :successful_completion
          })
        end

        it 'is not discretionary' do
          expect(subject.discretionary?).to eq false
        end

        context 'when it includes a DUI charge' do
          context 'when the subsection is in parens' do
            let(:dui_count) { build_count(code: 'VC', section: '23152(c)', dispositions: [build_disposition(sentence: sentence, date: date)]) }
            let(:conviction_event) do
              build_court_event(
                counts: [count, dui_count],
                date: Date.new(1991, 5, 1)
              )
            end

            it 'returns discretionary' do
              expect(subject.remedy_details).to eq ({
                code: '1203.4',
                scenario: :discretionary
              })
            end

            it 'is discretionary' do
              expect(subject.discretionary?).to eq true
            end
          end

          context 'when the subsection includes periods' do
            let(:dui_count) { build_count(code: 'VC', section: '14601.6', dispositions: [build_disposition(sentence: sentence, date: date)]) }
            let(:conviction_event) do
              build_court_event(
                counts: [count, dui_count],
                date: Date.new(1991, 5, 1)
              )
            end

            it 'returns discretionary' do
              expect(subject.remedy_details).to eq ({
                code: '1203.4',
                scenario: :successful_completion
              })
            end

            it 'is discretionary' do
              expect(subject.discretionary?).to eq false
            end
          end

          context 'when the subsection is improperly formatted' do
            let(:dui_count) { build_count(code: 'VC', section: '23145/23152(b)', dispositions: [build_disposition(sentence: sentence, date: date)]) }
            let(:conviction_event) do
              build_court_event(
                counts: [count, dui_count],
                date: Date.new(1991, 4, 1)
              )
            end

            it 'returns discretionary' do
              expect(subject.remedy_details).to eq ({
                code: '1203.4',
                scenario: :discretionary
              })
            end

            it 'is discretionary' do
              expect(subject.discretionary?).to eq true
            end
          end
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
          expect(subject.remedy_details).to eq ({
            code: '1203.4',
            scenario: :discretionary
          })
        end

        it 'is discretionary' do
          expect(subject.discretionary?).to eq true
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

        it 'returns nil' do
          expect(subject.remedy_details).to eq nil
        end
      end
    end

    context 'sentence does not include probation' do
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: nil) }
      let(:code) {'PC'}
      let(:section) {'123'}
      let(:count) { build_count(code: code, section: section, dispositions: [build_disposition(severity: severity, sentence: sentence, date: date)]) }
      let(:court_date) { Date.new(1991, 5, 1) }
      let(:conviction_event) do
        build_court_event(
          date: court_date,
          counts: [count]
        )
      end

      let(:arrest_event) { build_other_event(event_type: 'arrest', date: arrest_date) }

      context 'when the event severity is misdemeanor' do
        let(:severity) { 'M' }

        context 'when rap sheet is clear for a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 7, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy_details).to eq({
                                                   code: '1203.4a',
                                                   scenario: :successful_completion
                                                 })
          end

          it 'is not discretionary' do
            expect(subject.discretionary?).to eq false
          end

          context 'when it includes a DUI charge' do
            let(:dui_count) { build_count(code: 'VC', section: '23152(c)', dispositions: [build_disposition(sentence: sentence, date: date)]) }
            let(:conviction_event) do
              build_court_event(
                counts: [count, dui_count],
                date: Date.new(1991, 5, 1)
              )
            end

            it 'returns discretionary' do
              expect(subject.remedy_details).to eq ({
                code: '1203.4a',
                scenario: :discretionary
              })
            end

            it 'is discretionary' do
              expect(subject.discretionary?).to eq true
            end
          end
        end

        context 'when rap sheet has event within a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 4, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and discretionary scenario' do
            expect(subject.remedy_details).to eq({
                                                   code: '1203.4a',
                                                   scenario: :discretionary
                                                 })
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end
        end
      end

      context 'when the event severity is infraction' do
        let(:severity) { 'I' }

        context 'when rap sheet is clear for a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 7, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and successful scenario' do
            expect(subject.remedy_details).to eq({
                                                   code: '1203.4a',
                                                   scenario: :successful_completion
                                                 })
          end

          it 'is not discretionary' do
            expect(subject.discretionary?).to eq false
          end
        end

        context 'when rap sheet has event within a year after sentencing' do
          let(:arrest_date) { Date.new(1992, 4, 1) }
          let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event]) }

          it 'returns 1203.4a and discretionary scenario' do
            expect(subject.remedy_details).to eq({
                                                   code: '1203.4a',
                                                   scenario: :discretionary
                                                 })
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end
        end
      end

      context 'when the event severity is felony' do

        context 'when the conviction is after Oct 1 2011' do
          let(:severity) { 'F' }
          let(:court_date) { Date.new(2011, 10, 2) }

          it 'returns 1203.41' do
            expect(subject.remedy_details[:code]).to eq '1203.41'
          end

          it 'is eligible' do
            expect(subject.eligible?).to eq true
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end
        end

        context 'when the conviction is before Oct 1 2011' do
          context 'when it has an AB 109 code section' do
            let(:code) { 'HS'}
            let(:section) { '7051'}
            let(:court_date) { Date.new(2011, 9, 25) }
            let(:severity) { 'F' }

            it 'returns 1203.42' do
              expect(subject.remedy_details[:code]).to eq '1203.42'
            end

            it 'is eligible' do
              expect(subject.eligible?).to eq true
            end

            it 'is discretionary' do
              expect(subject.discretionary?).to eq true
            end
          end

          context 'when does not have an AB 109 code section' do
            let(:code) { 'PC'}
            let(:section) { '333333333'}
            let(:court_date) { Date.new(2011, 9, 25) }
            let(:severity) { 'F' }
            it 'returns 1203.42' do
              expect(subject.eligible?).to eq false
            end
          end
        end
      end

      context 'unknown severity' do
        let(:severity) { nil }

        it 'returns nil' do
          expect(subject.remedy_details).to eq nil
        end

        it 'discretionary returns nil' do
          expect(subject.discretionary?).to eq nil
        end
      end
    end
  end
end
