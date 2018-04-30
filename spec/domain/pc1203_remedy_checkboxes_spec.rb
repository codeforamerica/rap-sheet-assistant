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
    it 'fills out questions 2, 2a, 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationGrantedReason[0]' => '1',
        'topmostSubform[0].Page2[0].DismissSection_cb[1]' => '1'
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
    it 'fills out questions 2, 2b, 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationGrantedReason[1]' => '2',
        'topmostSubform[0].Page2[0].DismissSection_cb[1]' => '1'
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
    it 'fills out questions 2, 2c, 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationGrantedReason[2]' => '3',
        'topmostSubform[0].Page2[0].DismissSection_cb[1]' => '1'
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
    it 'fills out question 2, no subcheckbox, 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page2[0].DismissSection_cb[1]' => '1'
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

    it 'fills out questions 3, 3a, 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationNotGrantedReason[1]' => '2',
        'topmostSubform[0].Page2[0].DismissSection_cb[0]' => '2'
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

    it 'fills out questions 3, 3b, 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationNotGrantedReason[0]' => '1',
        'topmostSubform[0].Page2[0].DismissSection_cb[0]' => '2'
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

    it 'fills out questions 3, no subcheckbox, 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]' => '1',
        'topmostSubform[0].Page2[0].DismissSection_cb[0]' => '2'
      )
    end
  end
  
  context '1203.41' do
    let(:remedy) do
      {
        code: '1203.41',
        scenario: nil
      }
    end

    it 'fills out questions 5 and 8' do
      expect(subject).to eq(
        'topmostSubform[0].Page2[0].OffenseWSentence_cb[1]' => '1',
        'topmostSubform[0].Page2[0].DismissSection_cb[3]' => '3'
      )
    end
  end
end
