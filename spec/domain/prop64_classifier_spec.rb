require 'rails_helper'

describe Prop64Classifier do
  let(:date) { Date.new(1994, 1, 2) }
  let(:sentence) {}

  let(:conviction_event) do
    build_court_event(date: date, counts: conviction_counts)
  end

  let(:dispo) { build_disposition(sentence: sentence, date: Date.new(2010, 1, 1)) }

  let(:conviction_counts) do
    [build_count(section: section, code: code, dispositions: [dispo])]
  end

  let(:rap_sheet) { nil }
  subject { described_class.new(event: conviction_event, rap_sheet: rap_sheet) }

  describe 'determining eligibility' do
    context 'when the count is an eligible code' do
      let(:code) { 'HS' }
      let(:section) { '11359' }
      it 'is eligible' do
        expect(subject).to be_eligible
        expect(subject.eligible_counts).to eq conviction_counts
      end

      context 'the conviction date is after 11/8/16' do
        let(:date) { Date.new(2017, 1, 2)}

        it 'is not eligible' do
          expect(subject).not_to be_eligible
          expect(subject.eligible_counts).to eq []
        end
      end

      context 'there is no conviction date' do
        let(:date) { nil }

        it 'is eligible' do
          expect(subject).to be_eligible
          expect(subject.eligible_counts).to eq conviction_counts
        end
      end
    end

    context 'when the count is a subsection of an eligible code' do
      let(:code) { 'HS' }
      let(:section) { '11359(a)' }
      it 'is eligible' do
        expect(subject).to be_eligible
        expect(subject.eligible_counts).to eq conviction_counts
      end
    end

    context 'when the count is an ineligible code' do
      let(:code) { 'HS' }
      let(:section) { '12345' }
      it 'is not eligible' do
        expect(subject).not_to be_eligible
        expect(subject.eligible_counts).to eq []
      end
    end

    context 'when the code section is nil' do
      let(:code) { 'HS' }
      let(:section) { '11359' }
      let(:conviction_count) { build_count(dispositions: [dispo], section: section, code: code) }
      let(:nil_count) { build_count(dispositions: [dispo], section: section, code: nil) }
      let(:conviction_counts) { [conviction_count, nil_count] }

      it 'skips counts with nil code sections' do
        expect(subject).to be_eligible
        expect(subject.eligible_counts).to eq [conviction_count]
      end
    end
  end

  describe '#remedy_details' do
    describe 'when the person is still serving their sentence' do
      let(:conviction_counts) { [
        build_count(dispositions: [dispo], section: '11359(a)(b)', code: 'HS'),
        build_count(dispositions: [dispo], section: 'blah', code: 'PC'),
        build_count(dispositions: [dispo], section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { 9.years.ago }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 10.year) }

      it 'returns resentencing for the scenario' do
        expect(subject.remedy_details).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :resentencing
        )
      end
    end

    describe 'when the person has completed their sentence' do
      let(:conviction_counts) { [
        build_count(dispositions: [dispo], section: '11359(a)(b)', code: 'HS'),
        build_count(dispositions: [dispo], section: 'blah', code: 'PC'),
        build_count(dispositions: [dispo], section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { 10.years.ago }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.month) }

      it 'returns redesignation for the scenario' do
        expect(subject.remedy_details).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :redesignation
        )
      end
    end

    describe 'when the date is unknown' do
      let(:conviction_counts) { [
        build_count(dispositions: [dispo], section: '11359(a)(b)', code: 'HS'),
        build_count(dispositions: [dispo], section: 'blah', code: 'PC'),
        build_count(dispositions: [dispo], section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { nil }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.month) }

      it 'returns unknown for the scenario' do
        expect(subject.remedy_details).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :unknown
        )
      end
    end
  end
end
