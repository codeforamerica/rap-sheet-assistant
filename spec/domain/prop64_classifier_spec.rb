require 'spec_helper'

require 'rap_sheet_parser'

describe Prop64Classifier do
  let(:date) {}
  let(:sentence) {}
  let(:code) {}
  let(:section) {}
  let(:user) { build(:user) }

  let(:conviction_event) do
    build(:conviction_event, date: date, sentence: sentence, counts: [conviction_count])
  end

  let(:conviction_count) do
    build(:conviction_count, section: section, code: code)
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
      expect(subject.eligible_counts).to eq [conviction_count]
    end
  end

  describe '#action' do
    context 'it is eligible for resentencing' do
      let(:date) { 2.months.ago }
      let(:sentence) { ConvictionSentence.new(jail: 1.year) }

      it 'returns resentencing' do
        expect(subject.action).to eq 'Resentencing'
      end
    end

    context 'it is eligible for redesignation' do
      let(:date) { 2.years.ago }
      let(:sentence) { ConvictionSentence.new(probation: 1.month) }

      it 'returns redesignation' do
        expect(subject.action).to eq 'Redesignation'
      end
    end
  end
end
