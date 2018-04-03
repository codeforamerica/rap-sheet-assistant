require 'rails_helper'

require 'rap_sheet_parser'

describe ConvictionSentence do
  describe '#total_duration' do
    it 'computes duration of both jail and probation periods' do
      expect(described_class.new(jail: 1.year).total_duration).to eq(1.year)
      expect(described_class.new(probation: 30.days).total_duration).to eq(30.days)
      expect(described_class.new(jail: 1.year, probation: 6.months).total_duration).to eq(1.year + 6.months)
    end
  end

  describe '#to_s' do
    it 'transforms probation and jail into strings and shows details' do
      result = described_class.new(jail: 6.months, details: ['fine']).to_s
      expect(result).to eq('6m jail, fine')
    end
  end
end
