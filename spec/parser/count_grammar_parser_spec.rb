require 'spec_helper'
require 'treetop'

Treetop.load 'app/parser/common_grammar'
Treetop.load 'app/parser/count_grammar'

require_relative '../../app/parser/event_syntax_nodes'
require_relative '../../app/parser/count_syntax_nodes'

describe CountGrammarParser do
  describe '#parse' do
    it 'parses code sections and disposition' do
      text = <<~TEXT
        496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '496'
      expect(count.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"

      expect(count.disposition_content).to be_a CountGrammar::Convicted
      expect(count.disposition_content.severity.text_value).to eq 'MISDEMEANOR'
      end

    it 'handles stray characters at the end of the disposition line' do
      text = <<~TEXT
        496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        DISPO:CONVICTED blah .
        CONV STATUS:MISDEMEANOR
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '496'
      expect(count.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"

      expect(count.disposition_content).to be_a CountGrammar::Convicted
      expect(count.disposition_content.severity.text_value).to eq 'MISDEMEANOR'
    end

    it 'can parse convictions with semicolon instead of colon' do
      text = <<~TEXT
        blah
        DISPO;CONVICTED
        CONV STATUS:FELONY
      TEXT

      count = described_class.new.parse(text)

      expect(count.disposition_content).to be_a CountGrammar::Convicted
    end

    it 'can parse convictions with missing severity lines' do
      text = <<~TEXT
        blah
        DISPO:CONVICTED
      TEXT

      count = described_class.new.parse(text)

      expect(count.disposition_content).to be_a CountGrammar::Convicted
    end

    it 'parses when charge is in the comments' do
      text = <<~TEXT
         SEE COMMENT FOR CHARGE
        DISPO:CONVICTED
        CONV STATUS:FELONY
        COM: SEN-X3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN
        COM: CNT 01 CHRG-484-487 (A) PC SECOND DEGREE
        DCN:T11389422131233123000545
      TEXT

      count = described_class.new.parse(text)
      expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
      expect(count.disposition_content).to be_a CountGrammar::Convicted

      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '484-487 (A)'
    end

    it 'parses when charge is in the comments' do
      text = <<~TEXT
         SEE COMMENT FOR CHARGE
        DISPO:CONVICTED
        CONV STATUS:FELONY
        COM: SEN-X3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN
        .COM: CHRG 490,2 PC
        DCN:T11389422131233123000545
      TEXT

      count = described_class.new.parse(text)
      expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
      expect(count.disposition_content).to be_a CountGrammar::Convicted

      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '490,2'
    end

    it 'parses code section when sentencing line exists' do
      text = <<~TEXT
         .-1170 (H) PC-SENTENCING
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '496'
      expect(count.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"
    end

    it 'parses out punctuation around code section number' do
      text = <<~TEXT
          -496. PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '496'
      expect(count.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"
    end
  end
end


