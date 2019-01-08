require 'rails_helper'

describe Prop64Classifier do
  let(:date) {}
  let(:sentence) {}

  let(:conviction_event) do
    build_court_event(date: date, counts: conviction_counts)
  end

  let(:dispo) { build_disposition(sentence: sentence) }

  let(:conviction_counts) do
    [build_count(section: section, code: code, disposition: dispo)]
  end

  let(:rap_sheet) { nil }
  subject { described_class.new(event: conviction_event, rap_sheet: rap_sheet) }

  describe '#eligible?' do
    context 'when the count is an eligible code' do
      let(:code) { 'HS' }
      let(:section) { '11359' }
      it 'returns true' do
        expect(subject).to be_eligible
      end
    end

    context 'when the count is a subsection of an eligible code' do
      let(:code) { 'HS' }
      let(:section) { '11359(a)' }
      it 'returns true' do
        expect(subject).to be_eligible
      end
    end

    context 'when the count is an ineligible code' do
      let(:code) { 'HS' }
      let(:section) { '12345' }
      it 'returns true' do
        expect(subject).not_to be_eligible
      end
    end
  end

  describe '#eligible_counts' do
    let(:code) { 'HS' }
    let(:section) { '11359' }
    it 'returns eligible counts' do
      expect(subject.eligible_counts).to eq conviction_counts
    end

    context 'when the code section is nil' do
      let(:conviction_count) { build_count(disposition: dispo, section: section, code: code) }
      let(:nil_count) { build_count(disposition: dispo, section: section, code: nil) }
      let(:conviction_counts) { [conviction_count, nil_count] }

      it 'skips counts with nil code sections' do
        expect(subject.eligible_counts).to eq [conviction_count]
      end
    end
  end

  describe '#remedy_details' do
    describe 'resentencing' do
      let(:conviction_counts) { [
        build_count(disposition: dispo, section: '11359(a)(b)', code: 'HS'),
        build_count(disposition: dispo, section: 'blah', code: 'PC'),
        build_count(disposition: dispo, section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { 2.months.ago }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 1.year) }

      it 'returns a list of eligible remedies and scenario' do
        expect(subject.remedy_details).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :resentencing
        )
      end
    end

    describe 'redesignation' do
      let(:conviction_counts) { [
        build_count(disposition: dispo, section: '11359(a)(b)', code: 'HS'),
        build_count(disposition: dispo, section: 'blah', code: 'PC'),
        build_count(disposition: dispo, section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { 2.years.ago }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.month) }

      it 'returns a list of eligible remedies and scenario' do
        expect(subject.remedy_details).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :redesignation
        )
      end
    end

    describe 'unknown' do
      let(:conviction_counts) { [
        build_count(disposition: dispo, section: '11359(a)(b)', code: 'HS'),
        build_count(disposition: dispo, section: 'blah', code: 'PC'),
        build_count(disposition: dispo, section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { nil }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.month) }

      it 'returns a list of eligible remedies and scenario' do
        expect(subject.remedy_details).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :unknown
        )
      end
    end
  end
end
