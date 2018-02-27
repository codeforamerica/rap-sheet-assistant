require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/pc1203_classifier'

describe PC1203Classifier do
  let(:sentence) { '3yr jail'}

  let(:conviction_event) do
    instance_double(ConvictionEvent, sentence: sentence)
  end

  let(:conviction_count) do
    instance_double(ConvictionCount, event: conviction_event)
  end

  describe '#potentially_eligible?' do
    context "when the conviction's sentence included prison" do
      let(:sentence) { '3yr prison'}

      it 'returns false' do
        expect(described_class.new(conviction_count)).not_to be_potentially_eligible
      end
    end

    context "when the conviction's sentence included 'prison ss'" do
      let(:sentence) { '1yr prison ss'}

      it 'returns true' do
        expect(described_class.new(conviction_count)).to be_potentially_eligible
      end
    end

    context "when the conviction's sentence did not include prison" do
      let(:sentence) { '3yr jail'}

      it 'returns true' do
        expect(described_class.new(conviction_count)).to be_potentially_eligible
      end
    end
  end
end
