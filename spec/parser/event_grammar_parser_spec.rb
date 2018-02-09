require 'spec_helper'
require 'treetop'

require_relative '../../app/parser/event_syntax_nodes'

Treetop.load 'app/parser/common_grammar'
Treetop.load 'app/parser/event_grammar'

RSpec.describe EventGrammarParser do
  describe '#parse' do
    subject { described_class.new.parse(text) }

    context 'parsing a court event' do
      let(:text) {
        <<~TEXT
          COURT:
          20040102  CASC SAN FRANCISCO CO fds

          CNT: 001  #346477
            496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
          COM: SENTENCE CONCURRENT WITH FILE #743-2:

          CNT: 002
          count 2 text
          DISPO:DISMISSED

          CNT: 003
          count 3 text
        TEXT
      }

      it 'parses a court event' do
        expect(subject).to be_a(EventGrammar::CourtEvent)
      end

      it 'identifies the date' do
        expect(subject.date.text_value).to eq('20040102')
      end

      it 'identifies the courthouse' do
        expect(subject.courthouse.text_value).to eq('CASC SAN FRANCISCO')
      end

      it 'identifies the case number' do
        expect(subject.case_number.text_value).to eq('#346477')
      end

      it 'identifies count data' do
        count_1 = subject.counts[0]
        expect(count_1.disposition).to be_a EventGrammar::Convicted
        expect(count_1.penal_code.code.text_value).to eq 'PC'
        expect(count_1.penal_code.number.text_value).to eq '496'
        expect(count_1.penal_code_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"

        count_2 = subject.counts[1]
        expect(count_2.disposition.text_value).to eq('DISPO:DISMISSED')
        count_3 = subject.counts[2]
        expect(count_3.disposition.text_value).to eq('')
      end
    end

    it 'can parse count ranges' do
      text = <<~TEXT
        COURT:
        20040102  SAN FRANCISCO

        CNT: 001-004  #346477
        blah
        CNT: 003-011
        count 3 text
      TEXT

      tree = described_class.new.parse(text)

      expect(tree.counts[0].text_value).to eq "CNT: 001-004  #346477\nblah\n"
      expect(tree.counts[1].text_value).to eq "CNT: 003-011\ncount 3 text\n"
    end

    it 'can parse two digit count' do
      text = <<~TEXT
        COURT:
        20040102  SAN FRANCISCO

        CNT: 01  #346477
        blah
        CNT: 02
        count 2 text
        CNT: 03-04
        count 3/4 text
      TEXT

      tree = described_class.new.parse(text)

      expect(tree.counts[0].text_value).to eq "CNT: 01  #346477\nblah\n"
      expect(tree.counts[1].text_value).to eq "CNT: 02\ncount 2 text\n"
      expect(tree.counts[2].text_value).to eq "CNT: 03-04\ncount 3/4 text\n"
    end

    it 'can parse convictions with semicolon instead of colon' do
      text = <<~TEXT
        COURT:
        20040102  SAN FRANCISCO

        CNT: 001  #346477
        blah
        DISPO;CONVICTED
      TEXT

      counts = described_class.new.parse(text).counts

      expect(counts[0].disposition).to be_a EventGrammar::Convicted
    end

    it 'can parse counts with extra whitespace' do
      text = <<~TEXT
        COURT:
        20040102  SAN FRANCISCO
        CNT : 003
        count 3 text
      TEXT

      tree = described_class.new.parse(text)

      expect(tree.counts[0].text_value).to eq "CNT : 003\ncount 3 text\n"
    end

    it 'can parse court identifier with extra whitespace' do
      text = <<~TEXT
        COURT :
        20040102  SAN FRANCISCO
        CNT : 003
        count 3 text
      TEXT

      subject = described_class.new.parse(text)

      expect(subject).to be_a(EventGrammar::CourtEvent)
    end

    it 'can parse case number even if first CNT number is not 001' do
      text = <<~TEXT
        COURT:
        20040102  SAN FRANCISCO
        CNT : 003 #312145
        count 3 text
      TEXT

      tree = described_class.new.parse(text)

      expect(tree.case_number.text_value).to eq('#312145')
    end

    it 'can parse case number even with stray punctuation and newlines' do
      text = <<~TEXT
        COURT:
        20040102  SAN FRANCISCO
        CNT :003.
         . #312145
        count 3 text
      TEXT

      tree = described_class.new.parse(text)

      expect(tree.case_number.text_value).to eq('#312145')
    end

    it 'parses unknown courthouse with TOC on the same line' do
      text = <<~TEXT
        COURT:
        20040102  NEW COURTHOUSE TOC:M
        CNT :003.
         . #312145
        count 3 text
      TEXT

      tree = described_class.new.parse(text)

      expect(tree.courthouse.text_value).to eq('NEW COURTHOUSE ')
    end

    it 'parses when charge is in the comments' do
      text = <<~TEXT
        COURT:
        20040102  NEW COURTHOUSE TOC:M
        CNT :003
         SEE COMMENT FOR CHARGE
        DISPO:CONVICTED
        count 3 text
      TEXT

      tree = described_class.new.parse(text)

      count = tree.counts[0].count_content
      expect(count.charge_line.text_value).to eq('SEE COMMENT FOR CHARGE')
      expect(count.disposition_content.text_value).to eq('DISPO:CONVICTED')
    end

    it 'parses penal code when sentencing line exists' do
      text = <<~TEXT
        COURT:
        20040102  CASC SAN FRANCISCO CO fds

        CNT: 001  #346477
         .-1170 (H) PC-SENTENCING
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      tree = described_class.new.parse(text)
      count_1 = tree.counts[0]
      expect(count_1.penal_code.code.text_value).to eq 'PC'
      expect(count_1.penal_code.number.text_value).to eq '496'
      expect(count_1.penal_code_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"
    end

    it 'parses out punctuation around penal code' do
      text = <<~TEXT
        COURT:
        20040102  CASC SAN FRANCISCO CO fds

        CNT: 001  #346477
          -496. PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      TEXT

      tree = described_class.new.parse(text)
      count_1 = tree.counts[0]
      expect(count_1.penal_code.code.text_value).to eq 'PC'
      expect(count_1.penal_code.number.text_value).to eq '496'
      expect(count_1.penal_code_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"
    end
  end
end
