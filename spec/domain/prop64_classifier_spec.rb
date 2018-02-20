require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/prop64_classifier'

describe Prop64Classifier do
  let(:event_data) {}
  let(:code_section) {}

  let(:count) do
    instance_double(Count, code_section: code_section, event: event_data)
  end

  describe '#eligible?' do
    context 'when the count is an eligible code' do
      let(:code_section) { 'HS 11359' }
      it 'returns true' do
        expect(described_class.new(count)).to be_eligible
      end
    end

    context 'when the count is an ineligible code' do
      let(:code_section) { 'HS 12345' }
      it 'returns true' do
        expect(described_class.new(count)).not_to be_eligible
      end
    end
  end

  describe '#action' do
    context 'it is eligible for resentencing' do
      let(:event_data) do
        {
          date: 2.months.ago,
          sentence: '1y jail'
        }
      end

      it 'returns resentencing' do
        expect(described_class.new(count).action).to eq 'Resentencing'
      end
    end

    context 'it is eligible for redesignation' do
      let(:event_data) {
        {
          date: 2.years.ago,
          sentence: '1m probation'
        }
      }
      it 'returns redesignation' do
        expect(described_class.new(count).action).to eq 'Redesignation'
      end
    end
  end
end
