require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/prop64_classifier'

describe Prop64Classifier do
  let(:date) {}
  let(:sentence) {}
  let(:code_section) {}

  let(:conviction_event) do
    instance_double(ConvictionEvent, date: date, sentence: sentence)
  end

  let(:conviction_count) do
    instance_double(ConvictionCount, code_section: code_section, event: conviction_event)
  end

  describe '#eligible?' do
    context 'when the count is an eligible code' do
      let(:code_section) { 'HS 11359' }
      it 'returns true' do
        expect(described_class.new(conviction_count)).to be_eligible
      end
    end

    context 'when the count is an ineligible code' do
      let(:code_section) { 'HS 12345' }
      it 'returns true' do
        expect(described_class.new(conviction_count)).not_to be_eligible
      end
    end
  end

  describe '#action' do
    context 'it is eligible for resentencing' do
      let(:date) { 2.months.ago }
      let(:sentence) { '1y jail' }

      it 'returns resentencing' do
        expect(described_class.new(conviction_count).action).to eq 'Resentencing'
      end
    end

    context 'it is eligible for redesignation' do
      let(:date) { 2.years.ago }
      let(:sentence) { '1m probation' }

      it 'returns redesignation' do
        expect(described_class.new(conviction_count).action).to eq 'Redesignation'
      end
    end
  end
end
