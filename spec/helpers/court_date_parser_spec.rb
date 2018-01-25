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

DISPO:CONVICTED

COURT:
19890112 CAMC SAN DIEGO

DISPO:CONVICTED

COURT :
19990511 CAMC SAN DIEGO

DISPO:CONVICTED"
'''
      expected_dates = [
        Date.new(1982, 9, 15),
        Date.new(1989, 1, 12),
        Date.new(1999, 5, 11),
      ]
      expect(described_class.parse(text)).to eq expected_dates
    end
  end
end
