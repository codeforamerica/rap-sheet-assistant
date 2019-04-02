require 'rails_helper'

describe Prop47Classifier do
  let(:rap_sheet) { build_rap_sheet(events: events) }
  subject { described_class.new(event: conviction_event, rap_sheet: rap_sheet) }
  let(:conviction_event) { build_court_event(counts: conviction_counts, date: date) }
  let(:date) { 9.years.ago }
  let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.year) }
  let(:prop47_count) { build_count(code: 'PC', section: '470', dispositions: [build_disposition(sentence: sentence, severity: severity, date: Date.new(2010,1,1))]) }
  let(:events) { [conviction_event] }


  describe 'determining eligiblity' do
    context 'when the event contains a Prop47 code' do
      let(:conviction_counts) { [prop47_count] }

      context 'when the Prop47 count is a misdemeanor' do
        let(:severity) { 'M' }
        it 'is not eligible' do
          expect(subject.eligible?).to be false
          expect(subject.eligible_counts).to eq []
        end
      end

      context 'when the Prop 47 count is a felony' do
        let(:severity) { 'F' }
        let(:conviction_counts) { [prop47_count] }

        context 'when there are no disqualifiers on the RAP sheet' do
          it 'is eligible' do
            expect(subject.eligible?).to be true
            expect(subject.eligible_counts).to eq [prop47_count]
          end

          context 'when the person is still serving their sentence' do
            let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 10.year) }

            it 'returns resentencing for the scenario' do
              expect(subject.remedy_details).to eq({ scenario: :resentencing })
            end
          end

          context 'when the person has completed their sentence' do
            it 'returns redesignation for the scenario' do
              expect(subject.remedy_details).to eq({ scenario: :redesignation })
            end
          end

          context 'and there are also no-prop47 counts in the event' do
            let(:prop47_count_2) { build_count(code: 'HS', section: '11377', dispositions: [build_disposition(severity: 'F', date: Date.new(2010,1,1))]) }
            let(:conviction_counts) { [prop47_count, build_count, prop47_count_2] }

            it 'selects the prop47 counts in eligible_counts' do
              expect(subject.eligible?).to be true
              expect(subject.eligible_counts).to eq [prop47_count, prop47_count_2]
            end
          end
        end

        context 'when the rap sheet has a superstrike' do
          let(:superstrike_event) { build_court_event(counts: [build_count(code: 'PC', section: '187')]) }
          let(:events) { [conviction_event, superstrike_event] }

          it 'is not eligible' do
            expect(subject.eligible?).to be false
            expect(subject.eligible_counts).to eq []
          end
        end

        context 'when the rap sheet has a sex offender registration' do
          let(:sex_offender_count) { build_count(code: 'PC', section: '290') }
          let(:registration_event) { build_other_event(counts: [sex_offender_count], event_type: 'registration') }
          let(:events) { [conviction_event, registration_event] }

          it 'is not eligible' do
            expect(subject.eligible?).to be false
            expect(subject.eligible_counts).to eq []
          end
        end
      end
    end

    context 'when the event does not contain a Prop47 code' do
      let(:events) { [conviction_event] }
      let(:conviction_counts) { [build_count, build_count(code: nil, section: nil), build_count(dispositions: [])] }

      it 'is not eligible' do
        expect(subject.eligible?).to be false
        expect(subject.eligible_counts).to eq []
      end
    end
  end
end
