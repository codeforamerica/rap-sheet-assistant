require 'spec_helper'

require_relative '../../app/domain/conviction_sentence'

describe ConvictionSentence do
  it 'computes a duration from the sentence string' do
    expect(ConvictionSentence.new('1y jail, fine').total_duration).to eq(1.year)
    expect(ConvictionSentence.new('30d probation').total_duration).to eq(30.days)
    expect(ConvictionSentence.new('1y jail, 6m probation').total_duration).to eq(1.year + 6.months)
  end
  
  describe '#to_s' do
    it 'downcases sentence text and changes units to single letter' do
      result = described_class.new('012 MONTHS PROBATION, 045 DAYS JAIL, FINE').to_s
      expect(result).to eq('12m probation, 45d jail, fine')
    end

    it 'removes periods' do
      result = described_class.new('01.2 MONTHS PROBATION').to_s
      expect(result).to eq('12m probation')
    end

    it 'removes quotes' do
      result = described_class.new("'006 MONTHS JAIL'").to_s
      expect(result).to eq('6m jail')
    end

    it 'standardizes restitution strings' do
      result = described_class.new('restn, rstn, restitution').to_s
      expect(result).to eq('restitution, restitution, restitution')
    end

    it 'replaces newlines with spaces' do
      result = described_class.new("006 MONTHS JAIL,\nFINE").to_s
      expect(result).to eq('6m jail, fine')
    end

    it 'replaces newlines with spaces' do
      result = described_class.new("006 MONTHS JAIL,\nFINE").to_s
      expect(result).to eq('6m jail, fine')
    end
  end
end
