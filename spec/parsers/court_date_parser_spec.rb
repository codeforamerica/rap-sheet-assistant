require 'rails_helper'

describe CourtDateParser do
  describe '.parse' do
    it 'parses conviction dates from text' do
      text = '''
COURT:
19740102 CASC SAN PRANCISCU rm

DISPO:DISMISSED/FURTHERANCE OF JUSTICE

COURT: NAME7OZ
19820915 CAMC L05 ANGELES METRO

DISPO:CONVICTED"
'''
      expected_dates = ['19820915']
      expect(described_class.parse(text)).to eq expected_dates
    end
  end
end
