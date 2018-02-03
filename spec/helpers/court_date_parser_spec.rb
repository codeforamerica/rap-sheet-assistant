require 'rails_helper'

describe CourtDateParser do
  describe '.parse' do
    it 'parses conviction dates from text' do
      text = <<~TEXT
        COURT:
        19740102 CASC SAN PRANCISCU rm
        
        #123
        DISPO:DISMISSED/FURTHERANCE OF JUSTICE
        
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        #456
        DISPO:CONVICTED
        
        COURT:
        19890112 CAMC SAN DIEGO
        
        #7 8   9
        DISPO:CONVICTED
        
        COURT :
        19990511 CAMC SAN DIEGO
        
        #abc
        DISPO:CONVICTED
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: '456',
        },
        {
          date: Date.new(1989, 1, 12),
          case_number: '789',
        },
        {
          date: Date.new(1999, 5, 11),
          case_number: 'abc',
        }
      ]
      expect(described_class.parse(text)).to eq expected_convictions
    end

    it 'discards text before the first "COURT" line' do
      text = <<~TEXT
        19820918
        #456
        DISPO:CONVICTED      

        COURT:
        19740102 CASC SAN PRANCISCU rm
        
        #123
        *DISPO:CONVICTED
      TEXT

      expected_convictions = [
        {
          date: Date.new(1974, 1, 2),
          case_number: '123',
        }
      ]
      expect(described_class.parse(text)).to eq expected_convictions
    end

    it 'strips trailing puncuation from case numbers' do
      text = <<~TEXT
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        #456.:
        DISPO:CONVICTED
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: '456',
        },
      ]
      expect(described_class.parse(text)).to eq expected_convictions
    end

    it 'strips periods from case numbers' do
      text = <<~TEXT
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        #45.6:
        DISPO:CONVICTED
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: '456',
        },
      ]
      expect(described_class.parse(text)).to eq expected_convictions
    end

    it 'ignores # characters on their own line' do
      text = <<~TEXT
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        #
        8
        #456:
        DISPO:CONVICTED
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: '456',
        },
      ]
      expect(described_class.parse(text)).to eq expected_convictions
    end

    it 'returns nil for unknown case numbers' do
      text = <<~TEXT
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        Blah blah
        
        DISPO:CONVICTED
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: nil,
        },
      ]
      expect(described_class.parse(text)).to eq expected_convictions
    end

    it 'replaces hyphens with dashes' do
      text = <<~TEXT
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        #4–5-6:
        DISPO:CONVICTED
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: '4-5-6',
        },
      ]
      expect(described_class.parse(text)).to eq expected_convictions
    end
  end
end
