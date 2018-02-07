require 'spec_helper'
require 'treetop'
require 'date'

require_relative '../../app/domain/rap_sheet_presenter'
require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'

describe RapSheetPresenter do
  describe '#convictions' do
    it 'only returns events with convictions' do
      text = <<~TEXT
        info
        * * * *
        COURT:
        19740102 CASC SAN PRANCISCU rm
        
        CNT: 001 #123
        DISPO:DISMISSED/FURTHERANCE OF JUSTICE
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #456
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: '456',
          courthouse: 'CAMC L05 ANGELES METRO'
        }
      ]

      tree = Parser.new.parse(text)
      expect(described_class.new(tree).convictions).to eq expected_convictions
    end

    it 'strips whitespace from case numbers' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #45      6
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = Parser.new.parse(text)
      expect(described_class.new(tree).convictions[0][:case_number]).to eq '456'
    end

    it 'strips trailing punctuation from case numbers' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #456.:
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = Parser.new.parse(text)
      expect(described_class.new(tree).convictions[0][:case_number]).to eq '456'
    end

    it 'strips periods from case numbers' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #4.5.6
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = Parser.new.parse(text)
      expect(described_class.new(tree).convictions[0][:case_number]).to eq '456'
    end

    it 'returns nil case number for an unknown count one' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19990909 CAMC L05 ANGELES METRO
        
        CNT: 002
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = Parser.new.parse(text)
      expect(described_class.new(tree).convictions[0][:case_number]).to eq nil
    end

    it 'returns nil case number for an unknown case number' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001
        garbled
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      tree = Parser.new.parse(text)
      expect(described_class.new(tree).convictions[0][:case_number]).to eq nil
    end

    it 'includes courthouse in the conviction data' do
      text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CASC SAN FRANCISCO CO

        CNT: 001
        garbled
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: nil,
          courthouse: 'CASC SAN FRANCISCO CO'
        }
      ]

      tree = Parser.new.parse(text)
      expect(described_class.new(tree).convictions).to eq expected_convictions
    end
  end

end
