require 'rails_helper'

require_relative '../../app/domain/pc1203_classifier'

describe PC1203Classifier do
  let(:rap_sheet) { build_rap_sheet(events: [conviction_event, arrest_event, other_conviction_event]) }

  let(:conviction_event) { build_court_event(date: conviction_date, counts: [count]) }
  let(:count) { build_count(code: code, section: section, dispositions: dispositions) }
  let(:code) { 'PC' }
  let(:section) { '12345' }
  let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 3.years, date: conviction_date) }
  let(:dispositions) { [build_disposition(severity: severity, sentence: sentence, date: conviction_date)] }
  let(:conviction_date) { Date.new(1991, 5, 1) }
  let(:severity) { 'M' }

  let(:arrest_event) { build_other_event(event_type: 'arrest', date: arrest_date) }
  let(:arrest_date) { Date.new(2004, 7, 21) }

  let(:other_conviction_event) { build_court_event(date: other_conviction_date, counts: [other_count]) }
  let(:other_conviction_date) { Date.new(1999, 12, 23) }
  let(:other_count) { build_count(dispositions: [build_disposition(sentence: RapSheetParser::ConvictionSentence.new(probation: 1.years, date: other_conviction_date), date: other_conviction_date)]) }

  subject { described_class.new(event: conviction_event, rap_sheet: rap_sheet) }

  context 'when the conviction has no date' do
    let(:conviction_date) { nil }

    it 'is not eligible' do
      expect(subject.eligible?).to be false
    end

    xit 'returns a warning' do
      expect(true).to be false
    end
  end

  context 'when the conviction has already been dismissed under PC 1203' do
    let(:sentence_disposition) { build_disposition(severity: severity, sentence: sentence, date: conviction_date) }
    let(:dismissal_disposition) { build_disposition(type: 'pc1203_dismissed', date: conviction_date) }
    let(:dispositions) { [sentence_disposition, dismissal_disposition] }

    it 'is not eligible' do
      expect(subject.eligible?).to be false
    end
  end

  describe 'excluded offenses' do
    let(:conviction_event) { build_court_event(date: conviction_date, counts: [count1, count2]) }

    context 'when all counts are excluded offenses' do
      let(:count1) { build_count(code: 'PC', section: '288a(c)', dispositions: dispositions) }
      let(:count2) { build_count(code: 'VC', section: '2800', dispositions: dispositions) }

      it 'is not eligible' do
        expect(subject.eligible?).to be false
      end

      it 'returns no eligible counts' do
        expect(subject.eligible_counts).to eq([])
      end
    end

    context 'when some counts are excluded offenses and some are eligible' do
      let(:count1) { build_count(code: 'PC', section: '288a(c)', dispositions: dispositions) }
      let(:count2) { build_count(code: 'PC', section: '123', dispositions: dispositions) }

      it 'is eligible' do
        expect(subject.eligible?).to be true
      end

      it 'returns the eligible counts' do
        expect(subject.eligible_counts).to eq([count2])
      end
    end
  end

  context 'probation sentences' do
    context 'sentence is not yet completed' do
      let(:conviction_date) { Date.today - 2.years }
      it 'is not eligible' do
        expect(subject.eligible?).to be false
      end
    end

    context 'the applicant is currently serving a sentence for a different case (including probation)' do
      let(:other_conviction_date) { Date.today - 6.months }
      it 'is not eligible' do
        expect(subject.eligible?).to be false
      end
    end

    context 'the applicant successfully completed probation' do
      context 'is not a code section that is always discretionary (some vehicle codes)' do
        it 'is eligible' do
          expect(subject.eligible?).to be true
        end

        it 'is mandatory' do
          expect(subject.discretionary?).to eq false
        end

        it 'returns 1203.4, successful completion' do
          expect(subject.remedy_details[:code]).to eq('1203.4')
          expect(subject.remedy_details[:scenario]).to eq(:successful_completion)
        end
      end

      context 'is a code section that is always discretionary (some vehicle codes)' do
        let(:code) { 'VC' }
        let(:section) { '23152(c)' }

        it 'is eligible' do
          expect(subject.eligible?).to be true
        end

        it 'is discretionary' do
          expect(subject.discretionary?).to eq true
        end

        it 'returns 1203.4, discretionary' do
          expect(subject.remedy_details[:code]).to eq('1203.4')
          expect(subject.remedy_details[:scenario]).to eq(:discretionary)
        end
      end
    end

    context 'the applicant had a probation violating event during their probation term' do
      let(:arrest_date) { conviction_date + 1.year }

      it 'is eligible' do
        expect(subject.eligible?).to be true
      end

      it 'is discretionary' do
        expect(subject.discretionary?).to eq true
      end

      it 'returns 1203.4, discretionary' do
        expect(subject.remedy_details[:code]).to eq('1203.4')
        expect(subject.remedy_details[:scenario]).to eq(:discretionary)
      end
    end

    context 'the applicant had a complex probation history including violations' do
      let(:dispositions) { [probation_sentence, probation_extended, sentence_modified] }

      let(:probation_sentence) {build_disposition(severity: severity, sentence: sentence, date: conviction_date)}
      let(:probation_extended) {build_disposition(type: 'other_disposition_type', sentence: RapSheetParser::ConvictionSentence.new(probation: 2.years), date: conviction_date + 2.years)}
      let(:sentence_modified) {build_disposition(type: 'sentence_modified', sentence: RapSheetParser::ConvictionSentence.new(jail: 10.days, probation: 3.year, date: conviction_date + 3.years), date: conviction_date + 3.years)}

      let(:arrest_date) { conviction_date + 42.months }

      it 'is eligible' do
        expect(subject.eligible?).to be true
      end

      it 'is discretionary' do
        expect(subject.discretionary?).to eq true
      end

      it 'returns 1203.4, discretionary' do
        expect(subject.remedy_details[:code]).to eq('1203.4')
        expect(subject.remedy_details[:scenario]).to eq(:discretionary)
      end
    end

    context 'probation was revoked' do
      let(:dispositions) { [probation_sentence, probation_revoked, sentence_modified] }

      let(:probation_sentence) {build_disposition(severity: severity, sentence: sentence, date: conviction_date)}
      let(:probation_revoked) {build_disposition(type: 'probation_revoked', date: conviction_date + 2.years)}
      let(:sentence_modified) {build_disposition(type: 'sentence_modified', sentence: RapSheetParser::ConvictionSentence.new(jail: 10.days, date: conviction_date + 3.years), date: conviction_date + 3.years)}

      it 'is eligible, if eligible when treated as a non-probation case' do
        expect(subject.eligible?).to be true
      end

      it 'is discretionary' do
        expect(subject.discretionary?).to eq true
      end

      it 'returns 1203.4a, discretionary' do
        expect(subject.remedy_details[:code]).to eq('1203.4a')
        expect(subject.remedy_details[:scenario]).to eq(:discretionary)
      end
    end

    xcontext 'sentence includes both probation and prison' do
      it 'returns a warning' do

      end
    end
  end

  context 'prison sentences (non-probation)' do
    let(:severity) { 'F' }
    let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: 5.years, probation: nil, date: conviction_date) }

    context 'code section falls under 1170(h) (realignment / felony jail sentences)' do
      let(:code) { 'HS' }
      let(:section) { '7051' }

      context 'date is pre- Oct 2011' do
        let(:conviction_date) { Date.new(2011, 9, 25) }

        context 'at least 2 years have passed since end of sentence' do
          it 'is eligible' do
            expect(subject.eligible?).to eq true
          end

          it 'returns 1203.42' do
            expect(subject.remedy_details[:code]).to eq '1203.42'
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end
        end

        context '2 years have not yet passed since end of sentence' do
          let(:sentence) { RapSheetParser::ConvictionSentence.new(prison: 7.years, probation: nil, date: conviction_date) }
          it 'is not eligible' do
            expect(subject.eligible?).to be false
          end
        end
      end

      context 'date is post- Oct 2011' do
        let(:conviction_date) { Date.new(2011, 10, 25) }

        it 'is ineligible' do
          expect(subject.eligible?).to be false
        end

        xit 'returns a warning'
      end
    end

    context 'code section does not fall under 1170(h)' do
      it 'is ineligible' do
        expect(subject.eligible?).to be false
      end
    end

    context 'code section does not fall under 1170(h), but DOES fall under 17(b)' do
      let(:code) { 'PC' }
      let(:section) { '186.22(b)(1)' }

      it 'is ineligible' do
        expect(subject.eligible?).to be false
      end
    end
  end

  context 'non-probation misdemeanors and infractions' do
    let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 6.months, probation: nil, date: conviction_date) }
    let(:severity) { 'I' }

    context 'it is less than a year from the conviction date' do
      let(:conviction_date) { Date.today - 8.months }
      it 'is not eligible' do
        expect(subject.eligible?).to be false
      end
    end

    context 'it is an excluded code section' do
      let(:code) { 'VC' }
      let(:section) { '2803' }
      it 'is not eligible' do
        expect(subject.eligible?).to be false
      end
    end

    context 'it is more than a year from the conviction date' do
      let(:conviction_date) { Date.today - 13.months }

      context 'the rap sheet is clear for 1 year after conviction date' do
        context 'is not a code section that is always discretionary (some vehicle codes)' do
          it 'is eligible' do
            expect(subject.eligible?).to be true
          end

          it 'is mandatory' do
            expect(subject.discretionary?).to eq false
          end

          it 'returns 1203.4a, successful completion' do
            expect(subject.remedy_details[:code]).to eq('1203.4a')
            expect(subject.remedy_details[:scenario]).to eq(:successful_completion)
          end
        end

        context 'is a code section that is always discretionary (some vehicle codes)' do
          let(:code) { 'VC' }
          let(:section) { '14601.5' }

          it 'is eligible' do
            expect(subject.eligible?).to be true
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end

          it 'returns 1203.4a, discretionary' do
            expect(subject.remedy_details[:code]).to eq('1203.4a')
            expect(subject.remedy_details[:scenario]).to eq(:discretionary)
          end
        end

        context 'is a weirdly formatted code section that is always discretionary (some vehicle codes)' do
          let(:code) { 'VC' }
          let(:section) { '23145/23152(b)' }

          it 'is eligible' do
            expect(subject.eligible?).to be true
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end

          it 'returns 1203.4a, discretionary' do
            expect(subject.remedy_details[:code]).to eq('1203.4a')
            expect(subject.remedy_details[:scenario]).to eq(:discretionary)
          end
        end
      end

      context 'when the rap sheet has another event within one year of conviction date' do
        let(:arrest_date) { Date.today - 2.months }

        it 'is eligible' do
          expect(subject.eligible?).to be true
        end

        it 'is discretionary' do
          expect(subject.discretionary?).to eq true
        end

        it 'returns 1203.4a, discretionary' do
          expect(subject.remedy_details[:code]).to eq('1203.4a')
          expect(subject.remedy_details[:scenario]).to eq(:discretionary)
        end
      end
    end
  end

  context 'non-probation, non-prison felonies' do
    let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 1.year, probation: nil, date: conviction_date) }
    let(:severity) { 'F' }

    context 'when the code section falls under PC 1170(h) for sentencing (realignment)' do
      let(:code) { 'PC' }
      let(:section) { '182(a)(2)' }

      context 'when it is less than two years from the end of sentence' do
        let(:conviction_date) { Date.today - 25.months }

        it 'is ineligible' do
          expect(subject.eligible?).to be false
        end
      end

      context 'when it is more than two years from the end of sentence' do
        context 'the date is post- Oct 2011' do
          let(:conviction_date) { Date.today - 4.years }

          it 'is eligible' do
            expect(subject.eligible?).to be true
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end

          it 'returns 1203.41' do
            expect(subject.remedy_details[:code]).to eq('1203.41')
          end
        end

        context 'the date is pre- Oct 2011' do
          let(:conviction_date) { Date.new(2011, 9, 20) }
          it 'is eligible' do
            expect(subject.eligible?).to be true
          end

          it 'is discretionary' do
            expect(subject.discretionary?).to eq true
          end

          it 'returns 1203.42' do
            expect(subject.remedy_details[:code]).to eq('1203.42')
          end
        end
      end
    end

    context 'when the code section does not fall under PC 1170(h), but DOES fall under 17(b)' do
      let(:conviction_event) { build_court_event(date: conviction_date, counts: [count1, count2, count3]) }

      context 'when all counts fall under 17(b) OR are already a misdemeanor' do
        let(:count1) { build_count(code: 'PC', section: '186.22(b)(1)', dispositions: dispositions) }
        let(:count2) { build_count(code: 'PC', section: '32', dispositions: dispositions) }
        let!(:count3) { build_count(code: 'PC', section: '12345', dispositions: [build_disposition(severity: 'M', date: conviction_date)]) }

        context 'it is less than a year from the conviction date' do
          let(:conviction_date) { Date.today - 8.months }
          it 'is not eligible' do
            expect(subject.eligible?).to be false
          end
        end

        context 'it is more than a year from the conviction date' do
          let(:conviction_date) { Date.today - 13.months }

          context 'the rap sheet is clear for 1 year after conviction date' do
            it 'is eligible' do
              expect(subject.eligible?).to be true
            end

            it 'is mandatory' do
              expect(subject.discretionary?).to eq false
            end

            it 'returns 1203.4a, successful completion' do
              expect(subject.remedy_details[:code]).to eq('1203.4a')
              expect(subject.remedy_details[:scenario]).to eq(:successful_completion)
            end
          end

          context 'when the rap sheet has another event within one year of conviction date' do
            let(:arrest_date) { Date.today - 2.months }

            it 'is eligible' do
              expect(subject.eligible?).to be true
            end

            it 'is discretionary' do
              expect(subject.discretionary?).to eq true
            end

            it 'returns 1203.4a, discretionary' do
              expect(subject.remedy_details[:code]).to eq('1203.4a')
              expect(subject.remedy_details[:scenario]).to eq(:discretionary)
            end
          end
        end
      end

      context 'when at least one count is a non-reducible felony' do
        let(:count1) { build_count(code: 'PC', section: '186.22(b)(1)', dispositions: dispositions) }
        let(:count2) { build_count(code: 'PC', section: '32', dispositions: dispositions) }
        let(:count3) { build_count(code: 'PC', section: '12345', dispositions: dispositions) }

        it 'is not eligible' do
          expect(subject.eligible?).to be false
        end
      end
    end
  end

  context 'non-probation, non-prison sentences with no severity' do
    let(:severity) { nil }
    let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 6.months, probation: nil, date: conviction_date) }

    it 'is not eligible' do
      expect(subject.eligible?).to be false
    end

    xit 'returns a warning' do
      expect(true).to be false
    end
  end
end
