require 'spec_helper'

describe PC1203RemedyCheckboxes do
  subject { described_class.new(remedy).fields }

  context '1203.4 successful completion' do
    let(:remedy) do
      {
        code: '1203.4',
        scenario: :successful_completion
      }
    end
    it 'fills out question 2 and 2a' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationGrantedReason[0]' => '1',
      )
    end
  end

  context '1203.4 probation terminated early' do
    let(:remedy) do
      {
        code: '1203.4',
        scenario: :early_termination
      }
    end
    it 'fills out question 2 and 2a' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationGrantedReason[1]' => '2',
      )
    end
  end

  context '1203.4 discretionary' do
    let(:remedy) do
      {
        code: '1203.4',
        scenario: :discretionary
      }
    end
    it 'fills out question 2 and 2c' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationGrantedReason[2]' => '3',
      )
    end
  end

  context '1203.4 unknown remedy' do
    let(:remedy) do
      {
        code: '1203.4',
        scenario: :unknown
      }
    end
    it 'fills out question 2 and no subcheckbox' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1'
      )
    end
  end

  context '1203.4a successful completion' do
    let(:remedy) do
      {
        code: '1203.4a',
        scenario: :successful_completion
      }
    end

    it 'fills out question 3 and 3a' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationNotGrantedReason[1]' => '2',
      )
    end
  end

  context '1203.4a discretionary' do
    let(:remedy) do
      {
        code: '1203.4a',
        scenario: :discretionary
      }
    end

    it 'fills out question 3 and 3b' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationNotGrantedReason[0]' => '1',
      )
    end
  end

  context '1203.4a unknown scenario' do
    let(:remedy) do
      {
        code: '1203.4a',
        scenario: :unknown
      }
    end

    it 'fills out question 3 and no subcheckbox' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]' => '1'
      )
    end
  end
end
