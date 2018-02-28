require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/pc1203_classifier'

describe PC1203Classifier do
  let(:sentence) { '3yr jail'}
  let(:severity) { 'M' }
  let(:user) { FactoryBot.build(:user) }

  let(:conviction_event) do
    instance_double(ConvictionEvent, sentence: sentence)
  end

  let(:conviction_count) do
    instance_double(ConvictionCount, event: conviction_event, severity: severity)
  end

  describe '#potentially_eligible?' do
    context "when the conviction's sentence included prison" do
      let(:sentence) { '3yr prison'}

      it 'returns false' do
        expect(described_class.new(user, conviction_count)).not_to be_potentially_eligible
      end
    end

    context "when the conviction's sentence included 'prison ss'" do
      let(:sentence) { '1yr prison ss'}

      it 'returns true' do
        expect(described_class.new(user, conviction_count)).to be_potentially_eligible
      end
    end

    context "when the conviction's sentence did not include prison" do
      let(:sentence) { '3yr jail'}

      it 'returns true' do
        expect(described_class.new(user, conviction_count)).to be_potentially_eligible
      end
    end

    it 'does not consider infractions to be eligible' do
      count = instance_double(ConvictionCount, event: conviction_event, severity: 'nil')
      expect(described_class.new(user, count)).not_to be_potentially_eligible

      count = instance_double(ConvictionCount, event: conviction_event, severity: 'I')
      expect(described_class.new(user, count)).not_to be_potentially_eligible

      count = instance_double(ConvictionCount, event: conviction_event, severity: 'M')
      expect(described_class.new(user, count)).to be_potentially_eligible

      count = instance_double(ConvictionCount, event: conviction_event, severity: 'F')
      expect(described_class.new(user, count)).to be_potentially_eligible
    end
  end

  describe '#eligible?' do
    let(:sentence) { '3yr jail'}
    let(:user) do
      FactoryBot.build(
        :user,
        on_parole: false,
        on_probation: false,
        outstanding_warrant: false,
        owe_fees: false
      )
    end

    context 'when the user is in good standing' do
      it 'returns true' do
        expect(described_class.new(user, conviction_count)).to be_eligible
      end
    end

    context 'when the user is on parole' do
      before do
        user.on_parole = true
      end

      it 'returns false' do
        expect(described_class.new(user, conviction_count)).not_to be_eligible
      end
    end

    context 'when the user is on probation' do
      before do
        user.on_probation = true
      end

      context 'and they have not yet finished 1/2 of their probation' do
        before do
          user.finished_half_of_probation = false
        end

        it 'returns false' do
          expect(described_class.new(user, conviction_count)).not_to be_eligible
        end
      end

      context 'and they have finished 1/2 of their probation' do
        before do
          user.finished_half_of_probation = true
        end

        it 'returns true' do
          expect(described_class.new(user, conviction_count)).to be_eligible
        end
      end
    end

    context 'when the user has a warrant' do
      before do
        user.outstanding_warrant = true
      end

      it 'returns false' do
        expect(described_class.new(user, conviction_count)).not_to be_eligible
      end
    end
  end
end
