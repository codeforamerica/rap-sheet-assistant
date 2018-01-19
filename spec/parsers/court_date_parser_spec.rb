require 'rails_helper'

describe CourtDateParser do
  describe '.parse' do
    it 'parses conviction dates from text' do
      text = '''
      CNT:04
192‘3(A} PCvVEH MANSL N/GRUSS NEGIJAH

COURT:
19740102 CASC SAN PRANCISCU rm

CNTiol ‘84321
537EKA) FC78UY/SELL ARTICLES W/IDENT REMOVED
DISPC:DISMISSSED/FURTHERANCE OF JUSTICE

COURT: NAME7OZ
19820915 CAMC L05 ANGELES METRO

CNTiol ‘84321
537EKA) FC78UY/SELL ARTICLES W/IDENT REMOVED
DISPC:DISMISSSED/FURTHERANCE OF JUSTICE"
'''
      expected_dates = [
        Date.new(1974, 1, 2),
        Date.new(1982, 9, 15),
      ]

      expect(described_class.parse(text)).to eq expected_dates
    end
  end
end
