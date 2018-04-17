require 'spec_helper'
require 'rap_sheet_parser'

RSpec.describe EventGrammarParser do
  describe '#parse' do
    context 'parsing a court event' do
      it 'parses' do
        text = <<~TEXT
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

        tree = parse(text)

        expect(tree).to be_a(EventGrammar::CourtEvent)

        expect(tree.date.text_value).to eq('20040102')

        expect(tree.courthouse.text_value).to eq('CASC SAN FRANCISCO')

        expect(tree.case_number.text_value).to eq('#346477')

        count_1 = tree.counts[0]
        expect(count_1.disposition).to be_a CountGrammar::Convicted
        expect(count_1.code_section.code.text_value).to eq 'PC'
        expect(count_1.code_section.number.text_value).to eq '496'
        expect(count_1.code_section_description.text_value).to eq "RECEIVE/ETC KNOWN STOLEN PROPERTY\n"

        count_2 = tree.counts[1]
        expect(count_2.disposition.text_value).to eq('DISPO:DISMISSED')
        count_3 = tree.counts[2]
        expect(count_3.disposition.text_value).to eq('')
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

        tree = parse(text)

        expect(tree.counts[0].text_value).to eq "CNT: 001-004  #346477\nblah\n"
        expect(tree.counts[1].text_value).to eq "CNT: 003-011\ncount 3 text\n"
      end

      it 'can parse dates with stray periods' do
        text = <<~TEXT
          COURT:
          20040.102 SAN FRANCISCO

          CNT: 001-004  #346477
          blah
        TEXT

        tree = parse(text)

        expect(tree.date.text_value).to eq '20040.102'
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

        tree = parse(text)

        expect(tree.counts[0].text_value).to eq "CNT: 01  #346477\nblah\n"
        expect(tree.counts[1].text_value).to eq "CNT: 02\ncount 2 text\n"
        expect(tree.counts[2].text_value).to eq "CNT: 03-04\ncount 3/4 text\n"
      end

      it 'can parse counts with extra whitespace' do
        text = <<~TEXT
          COURT:
          20040102  SAN FRANCISCO
          CNT : 003
          count 3 text
        TEXT

        tree = parse(text)

        expect(tree.counts[0].text_value).to eq "CNT : 003\ncount 3 text\n"
      end

      it 'can parse counts with extra dashes' do
        text = <<~TEXT
          COURT:
          20040102  SAN FRANCISCO
          CNT:0-03
          count 3 text
        TEXT

        tree = parse(text)

        expect(tree.counts[0].text_value).to eq "CNT:0-03\ncount 3 text\n"
      end

      it 'can parse court identifier with extra whitespace' do
        text = <<~TEXT
          COURT :
          20040102  SAN FRANCISCO
          CNT : 003
          count 3 text
        TEXT

        subject = parse(text)

        expect(subject).to be_a(EventGrammar::CourtEvent)
      end

      it 'can parse case number even if first CNT number is not 001' do
        text = <<~TEXT
          COURT:
          20040102  SAN FRANCISCO
          CNT : 003 #312145
          count 3 text
        TEXT

        tree = parse(text)

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

        tree = parse(text)

        expect(tree.case_number.text_value).to eq('#312145')
      end

      it 'returns nil case number for an unknown case number' do
        text = <<~TEXT
          COURT: NAME7OZ
          19820915 CAMC L05 ANGELES METRO

          CNT: 001
          garbled
          DISPO:CONVICTED
        TEXT

        tree = parse(text)

        expect(tree.case_number).to eq nil
      end

      it 'parses unknown courthouse with TOC on the same line' do
        text = <<~TEXT
          COURT:
          20040102  NEW COURTHOUSE TOC:M
          CNT :003.
           . #312145
          count 3 text
        TEXT

        tree = parse(text)

        expect(tree.courthouse.text_value).to eq('NEW COURTHOUSE ')
      end

      it 'parses courthouse with NAM identifier in front' do
        text = <<~TEXT
          COURT:
          20040102
          NAM:001
          NEW COURTHOUSE
          CNT: 001 #312145
          count 3 text
        TEXT

        tree = parse(text)

        expect(tree.courthouse.text_value).to eq('NEW COURTHOUSE')
      end

      it 'sets sentence correctly if sentence modified' do
        text = <<~TEXT
          COURT:
          20040102  CASC SAN FRANCISCO CO

          CNT: 001 #346477
            496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL

          20040202
            DISPO :SOMETHING ELSE

          20040202
            DISPO:SENTENCE MODIFIED
            SEN: 001 MONTHS JAIL
        TEXT

        tree = parse(text)

        expect(tree.sentence.text_value).to eq('001 MONTHS JAIL')
      end
    end

    context 'parsing an arrest event' do
      it 'parses' do
        text = <<~TEXT
          ARR/DET/CITE:
          NAM:001
          19910105 CAPD CONCORD
          TOC:F
          CNT:001
          #65131
          496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        TEXT

        subject = parse(text)
        expect(subject).to be_a(EventGrammar::ArrestEvent)
        expect(subject.date.text_value).to eq '19910105'
      end

      it 'handles content before the arrest header' do
        text = <<~TEXT
          NAM:001
          ARR/DET/CITE:
          19910105 CAPD CONCORD
          TOC:F
          CNT:001
          #65131
          496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        TEXT

        subject = parse(text)
        expect(subject).to be_a(EventGrammar::ArrestEvent)
        expect(subject.date.text_value).to eq '19910105'
      end

      it 'handles whitespace and stray punctuation in arrest header' do
        text = <<~TEXT
          ARR / DET. / CITE:
          19910105 CAPD CONCORD
          TOC:F
          CNT:001
          #65131
          496.1 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
        TEXT

        subject = parse(text)
        expect(subject).to be_a(EventGrammar::ArrestEvent)
        expect(subject.date.text_value).to eq '19910105'
      end
    end

    context 'parsing a custody event' do
      it 'parses' do
        text = <<~TEXT
          CUSTODY:JAIL
          NAM:001
          20120503 CASO MARTINEZ
          CNT:001 #Cc12EA868A-070KLK602
          459 PC-BURGLARY
          TOC:F
        TEXT

        subject = parse(text)
        expect(subject).to be_a(EventGrammar::CustodyEvent)
        expect(subject.date.text_value).to eq '20120503'
      end

      it 'handles content before the custody header' do
        text = <<~TEXT
          NAM:001
          CUSTODY:JAIL
          20120503 CASO MARTINEZ
          CNT:001 #Cc12EA868A-070KLK602
          459 PC-BURGLARY
          TOC:F
        TEXT

        subject = parse(text)
        expect(subject).to be_a(EventGrammar::CustodyEvent)
        expect(subject.date.text_value).to eq '20120503'
      end

      it 'handles whitespace and stray punctuation in the header' do
        text = <<~TEXT
           . CUSTODY* *:JAIL
          20120503 CASO MARTINEZ
          CNT:001 #Cc12EA868A-070KLK602
          459 PC-BURGLARY
          TOC:F
        TEXT

        subject = parse(text)
        expect(subject).to be_a(EventGrammar::CustodyEvent)
        expect(subject.date.text_value).to eq '20120503'
      end
    end
  end
end

def parse(text)
  described_class.new.parse(text)
end
