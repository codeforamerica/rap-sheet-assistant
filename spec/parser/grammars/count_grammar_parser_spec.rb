require 'spec_helper'
require 'rap_sheet_parser'

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

      expect(count.disposition).to be_a CountGrammar::Convicted
      expect(count.disposition.severity.text_value).to eq 'MISDEMEANOR'
      expect(count.disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL'
      expect(count.disposition.sentence.probation.text_value).to eq '012 MONTHS PROBATION'
      expect(count.disposition.sentence.jail.text_value).to eq '045 DAYS JAIL'
    end

    it 'handles stray characters and whitespace in the disposition line' do
      text = <<~TEXT
        496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        DI SP O:CONVICTED blah .
        CONV STATUS:MISDEMEANOR
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '496'
      expect(count.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"

      expect(count.disposition).to be_a CountGrammar::Convicted
      expect(count.disposition.severity.text_value).to eq 'MISDEMEANOR'
    end

    it 'can parse convictions with semicolon instead of colon' do
      text = <<~TEXT
        blah
        DISPO;CONVICTED
        CONV STATUS:FELONY
      TEXT

      count = described_class.new.parse(text)

      expect(count.disposition).to be_a CountGrammar::Convicted
    end

    it 'can parse convictions with missing severity lines' do
      text = <<~TEXT
        blah
        DISPO:CONVICTED
      TEXT

      count = described_class.new.parse(text)

      expect(count.disposition).to be_a CountGrammar::Convicted
    end

    it 'can parse whitespace in severity lines' do
      text = <<~TEXT
        DISPO:CONVICTED
         CONV STATUS : FELONY
      TEXT

      count = described_class.new.parse(text)

      expect(count.disposition.severity.text_value).to eq 'FELONY'
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
      expect(count.disposition).to be_a CountGrammar::Convicted

      expect(count.code_section.code.text_value).to eq 'PC'
      expect(count.code_section.number.text_value).to eq '484-487 (A)'
    end

    it 'parses malformed charge comments' do
      text = <<~TEXT
         SEE COMMENT FOR CHARGE
        DISPO:CONVICTED
        CONV STATUS:FELONY
        COM: SEN-X3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN
        .COM; CHRG 490,2 PC
        DCN:T11389422131233123000545
      TEXT

      count = described_class.new.parse(text)
      expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
      expect(count.disposition).to be_a CountGrammar::Convicted
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

    it 'parses multiple line sentences where the sentence is last' do
      text = <<~TEXT
         .-1170 (H) PC-SENTENCING
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS,
             CONCURRENT
      TEXT

      count = described_class.new.parse(text)
      expect(count.disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
    end

    it 'parses out junk characters from sentences' do
      text = <<~TEXT
         .-1170 (H) PC-SENTENCING
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        ' SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT
        - .
      TEXT

      count = described_class.new.parse(text)
      expect(count.disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
    end

    it 'parses multiple line sentences where another specific line type comes after the sentence' do
      text = <<~TEXT
         .-1170 (H) PC-SENTENCING
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS,
             CONCURRENT
        COM: hello world
      TEXT

      count = described_class.new.parse(text)
      expect(count.disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
    end

    it 'parses multiple line sentences where a date marker comes after the sentence' do
      text = <<~TEXT
         .-1170 (H) PC-SENTENCING
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS,
             CONCURRENT
        20130116
      TEXT

      count = described_class.new.parse(text)
      expect(count.disposition.sentence.text_value).to eq '012 MONTHS PROBATION, 045 DAYS JAIL, FINE, FINE SS, CONCURRENT'
    end
    
    it 'parses sentences found in comments with a SEN-X header' do
      text = <<~TEXT
        496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        COM: SEN-X3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN
        COM: CNT 01 CHRG-484-487 (A) PC
      TEXT

      count = described_class.new.parse(text)
      expect(count.disposition.sentence.text_value).to eq '3 YR PROB, 6 MO JL WORK, $971 FINE $420 RSTN'
      expect(count.disposition.sentence.probation.text_value).to eq '3 YR PROB'
      expect(count.disposition.sentence.jail.text_value).to eq '6 MO JL WORK'
      expect(count.disposition.sentence.details[0].text_value).to eq '$971 FINE $420 RSTN'
    end
    
    it 'parses sentences found in comments with an XSEN header' do
      text = <<~TEXT
        SEE COMMENT FOR CHARGE
        *DISPO: CONVICTED
        CONV STATUS :MISDEMEANOR
        COM: XSEN:3 YR PROB,90 DS JL, FINE FNSS RSTN
        COM: CNT 02 CHRG-666 PC
        DCN:T6014082460234000096
      TEXT

      count = described_class.new.parse(text)
      expect(count.disposition.sentence.text_value).to eq '3 YR PROB,90 DS JL, FINE FNSS RSTN'
      expect(count.disposition.sentence.probation.text_value).to eq '3 YR PROB'
      expect(count.disposition.sentence.jail.text_value).to eq '90 DS JL'
      expect(count.disposition.sentence.details[0].text_value).to eq 'FINE FNSS RSTN'
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

    it 'ignores "TRAFFIC VIOLATION" when looking for conviction codes' do
      text = <<~TEXT
        TRAFFIC VIOLATION
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 003 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      count = described_class.new.parse(text)
      expect(count.code_section).to be_nil
    end
  end
end
