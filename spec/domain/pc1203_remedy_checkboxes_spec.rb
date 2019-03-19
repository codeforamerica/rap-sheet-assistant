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
    it 'fills out questions 2, 2a' do
      expect(subject).to eq(
                           'Field43' => 'Yes',
                           'Field44' => 'Yes',
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
    it 'fills out questions 2, 2b' do
      expect(subject).to eq(
                           'Field43' => 'Yes',
                           'Field45' => 'Yes',
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
    it 'fills out questions 2, 2c' do
      expect(subject).to eq(
                           'Field43' => 'Yes',
                           'Field46' => 'Yes',
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
    it 'fills out question 2, no subcheckbox' do
      expect(subject).to eq('Field43' => 'Yes',)
    end
  end

  context '1203.4a successful completion' do
    let(:remedy) do
      {
        code: '1203.4a',
        scenario: :successful_completion
      }
    end

    it 'fills out questions 3, 3a' do
      expect(subject).to eq(
                           'Field51' => 'Yes',
                           'Field52' => 'Yes',
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

    it 'fills out questions 3, 3b' do
      expect(subject).to eq(
                           'Field51' => 'Yes',
                           'Field53' => 'Yes',
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

    it 'fills out questions 3, no subcheckbox' do
      expect(subject).to eq('Field51' => 'Yes',)
    end
  end

  context '1203.41' do
    let(:remedy) do
      {
        code: '1203.41',
        scenario: nil
      }
    end

    it 'fills out question 5' do
      expect(subject).to eq('Field57' => 'Yes',)
    end
  end

  context '1203.42' do
    let(:remedy) do
      {
        code: '1203.42',
        scenario: nil
      }
    end

    it 'fills out question 6' do
      expect(subject).to eq('Field64' => 'Yes',)
    end
  end
end
