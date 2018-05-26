require 'spec_helper'

require 'rap_sheet_parser'

describe Prop64Classifier do
  let(:date) {}
  let(:sentence) {}
  let(:user) { build(:user) }

  let(:conviction_event) do
    build_conviction_event(date: date, sentence: sentence, counts: conviction_counts)
  end

  let(:conviction_counts) do
    [build_conviction_count(section: section, code: code)]
  end

  let(:event_collection) { nil }
  subject { described_class.new(user: user, event: conviction_event, event_collection: event_collection) }

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
      let(:conviction_count) { build_conviction_count(section: section, code: code) }
      let(:nil_count) { build_conviction_count(section: section, code: nil) }
      let(:conviction_counts) { [conviction_count, nil_count] }

      it 'skips counts with nil code sections' do
        expect(subject.eligible_counts).to eq [conviction_count]
      end
    end
  end

  describe '#remedy' do
    describe 'resentencing' do
      let(:conviction_counts) { [
        build_conviction_count(section: '11359(a)(b)', code: 'HS'),
        build_conviction_count(section: 'blah', code: 'PC'),
        build_conviction_count(section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { 2.months.ago }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(jail: 1.year) }

      it 'returns a list of eligible remedies and scenario' do
        expect(subject.remedy).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :resentencing
        )
      end
    end

    describe 'redesignation' do
      let(:conviction_counts) { [
        build_conviction_count(section: '11359(a)(b)', code: 'HS'),
        build_conviction_count(section: 'blah', code: 'PC'),
        build_conviction_count(section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { 2.years.ago }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.month) }

      it 'returns a list of eligible remedies and scenario' do
        expect(subject.remedy).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :redesignation
        )
      end
    end

    describe 'unknown' do
      let(:conviction_counts) { [
        build_conviction_count(section: '11359(a)(b)', code: 'HS'),
        build_conviction_count(section: 'blah', code: 'PC'),
        build_conviction_count(section: '11362.1(c)', code: 'HS')
      ] }

      let(:date) { nil }
      let(:sentence) { RapSheetParser::ConvictionSentence.new(probation: 1.month) }

      it 'returns a list of eligible remedies and scenario' do
        expect(subject.remedy).to eq(
          codes: ['HS 11359', 'HS 11362.1'],
          scenario: :unknown
        )
      end
    end
  end
end

def build_conviction_count(code:'PC', section:'123', severity:'M')
  RapSheetParser::ConvictionCount.new(
    event: double(:event),
    code_section_description: 'foo',
    severity: severity,
    code: code,
    section: section)
end

def build_conviction_event(
  date: Date.new(1994, 1, 2),
  case_number: '12345',
  courthouse: 'CASC SAN FRANCISCO',
  sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
  counts: []
)

  event = RapSheetParser::ConvictionEvent.new(
    date: date, courthouse: courthouse, case_number: case_number, sentence: sentence)
  event.counts = counts
  event
end
