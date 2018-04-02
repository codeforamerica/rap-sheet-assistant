require 'spec_helper'

require_relative '../../app/domain/pc1203_classifier'

describe PC1203Classifier do
  let(:user) { FactoryBot.build(:user) }

  let(:conviction_event) do
    instance_double(ConvictionEvent, sentence: sentence)
  end

  subject { described_class.new(user, conviction_event) }

  describe '#potentially_eligible?' do
    context "when the conviction's sentence had prison" do
      let(:sentence) { double(ConvictionSentence, had_prison?: true) }

      it 'returns false' do
        expect(subject).not_to be_potentially_eligible
      end
    end

    context "when the conviction's sentence did not include prison" do
      let(:sentence) { double(ConvictionSentence, had_prison?: false) }

      it 'returns true' do
        expect(subject).to be_potentially_eligible
      end
    end
  end

  describe '#eligible?' do
    let(:sentence) { double(ConvictionSentence, had_prison?: false) }
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
        expect(subject).to be_eligible
      end
    end

    context 'when the user is on parole' do
      before do
        user.on_parole = true
      end

      it 'returns false' do
        expect(subject).not_to be_eligible
      end
    end

    context 'when the user is on probation' do
      before do
        user.on_probation = true
      end

      xcontext 'and they have not yet finished 1/2 of their probation' do
        before do
          user.finished_half_of_probation = false
        end

        it 'returns false' do
          expect(subject).not_to be_eligible
        end
      end

      xcontext 'and they have finished 1/2 of their probation' do
        before do
          user.finished_half_of_probation = true
        end

        it 'returns true' do
          expect(subject).to be_eligible
        end
      end
    end

    context 'when the user has a warrant' do
      before do
        user.outstanding_warrant = true
      end

      it 'returns false' do
        expect(subject).not_to be_eligible
      end
    end
  end

  describe '#remedy' do
    context 'sentence includes probation' do
      let(:conviction_event) do
        instance_double(ConvictionEvent, sentence: instance_double(ConvictionSentence, had_probation?: true))
      end

      it 'returns 1203.4' do
        expect(subject.remedy).to eq '1203.4'
      end
    end

    context 'sentence does not include probation' do
      let(:conviction_event) do
        instance_double(ConvictionEvent,
                        sentence: instance_double(ConvictionSentence, had_probation?: false),
                        severity: severity)
      end

      context 'when the event severity is misdemeanor' do
        let(:severity) { 'M' }

        it 'returns 1203.4a' do
          expect(subject.remedy).to eq '1203.4a'
        end
      end

      context 'when the event severity is infraction' do
        let(:severity) { 'I' }

        it 'returns 1203.4a' do
          expect(subject.remedy).to eq '1203.4a'
        end
      end

      context 'when the event severity is felony' do
        let(:severity) { 'F' }

        it 'returns 1203.41' do
          expect(subject.remedy).to eq '1203.41'
        end
      end

      context 'unknown severity' do
        let(:severity) { nil }

        it 'returns nil' do
          expect(subject.remedy).to eq nil
        end
      end
    end
  end
end
