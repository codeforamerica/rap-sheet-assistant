require 'rails_helper'

RSpec.describe TranscriptPresenter do
  describe '#rows' do
    let(:text) do
      <<~TEXT
        info
        * * * *
        COURT:  NAM:02
        19880420 CASC SAN FRANCISCO CO
        CNT:01 #05378
          11352 HS-TRANSPORT/SELL

        DISPO:DISMISSED
          SEN: 3 YEARS PROBATION
        * * * END OF MESSAGE * * *
      TEXT
    end

    let(:rap_sheet) do
      create(:rap_sheet,
             number_of_pages: 1,
             rap_sheet_pages: [RapSheetPage.new(text: text, page_number: 1)]
      )
    end
    let(:transcript) { TranscriptPresenter.new(rap_sheet) }

    let(:transcript_rows) { transcript.rows }
    context 'a court event does not have any convicted events' do
      let(:text) do
        <<~TEXT
          info
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            11352 HS-TRANSPORT/SELL

          DISPO:DISMISSED
            SEN: 3 YEARS PROBATION
          * * * END OF MESSAGE * * *
        TEXT
      end

      it 'does not display the event on the transcript page' do
        expect(transcript_rows.length).to eq 0
      end
    end

    context 'all counts in a court event are convicted' do
      let(:text) do
        <<~TEXT
          info
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            11352 HS-TRANSPORT/SELL

          DISPO:CONVICTED
            SEN: 3 YEARS PROBATION
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            11352 HS-TRANSPORT/SELL

          DISPO:CONVICTED
            SEN: 3 YEARS PROBATION

          CNT:02 #05378
            11357 HS-POSSES

          DISPO:CONVICTED
            SEN: 3 YEARS PROBATION
          * * * END OF MESSAGE * * *
        TEXT
      end
      it 'displays all counts on the page' do
        expect(transcript_rows.length).to eq 3
      end
    end

    context 'a page number splits the count' do
      let(:text) do
        <<~TEXT
          info
          * * * *
           COURT:
          20040102  CASC SAN FRANCISCO CO

          CNT: 001  #346477
          Page 2 of 29
          496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
          CONV STATUS:MISDEMEANOR
          SEN: 012 MONTHS PROBATION, 045 DAYS JAIL

          CNT:002
          Page 13 of 16
          11357 HS-POSSESS
          TOC:M
          *DISPO:CONVICTED
          CONV STATUS:FELONY
          SEN: 002 YEARS PROBATION, 045 DAYS JAIL, FINE, IMP SEN SS
          * * * END OF MESSAGE * * *
        TEXT
      end

      it 'shows the code section without the page number' do
        expect(transcript_rows.length).to eq 2
        expect(transcript_rows[0][:code_section]).to eq 'PC 496'
        expect(transcript_rows[0][:probation]).to eq '12 months'

        expect(transcript_rows[1][:code_section]).to eq 'HS 11357'
        expect(transcript_rows[1][:probation]).to eq '2 years'
      end
    end

    context 'some counts in a court event are convicted and some are not' do
      let(:text) do
        <<~TEXT
          info
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            11352 HS-TRANSPORT/SELL

          DISPO:CONVICTED
            SEN: 3 YEARS PROBATION
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            11352 HS-TRANSPORT/SELL

          DISPO:CONVICTED
            SEN: 3 YEARS PROBATION

          CNT:02 #05378
            11357 HS-POSSES

          DISPO:DISMISSED
            SEN: 3 YEARS PROBATION
          * * * END OF MESSAGE * * *
        TEXT
      end
      it 'only displays convicted counts' do
        expect(transcript_rows.length).to eq 2
      end
    end

    context 'the sentence is only listed on one conviction in an event' do
      let(:text) do
        <<~TEXT
          info
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            11352 HS-TRANSPORT/SELL

          DISPO:CONVICTED
            SEN: 3 YEARS PROBATION
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            55555 HS-TRANSPORT/SELL

          DISPO:CONVICTED

          CNT:02 #05378
            11357 HS-POSSES

          DISPO:DISMISSED

          CNT:03 #05378
            11357 HS-POSSES

          DISPO:CONVICTED
            SEN: 2 YEARS PRISON
          * * * END OF MESSAGE * * *
        TEXT
      end
      it 'fills out the same sentence for all convictions in any given event' do
        expect(transcript_rows.length).to eq 3
        expect(transcript_rows[0][:code_section]).to eq 'HS 11352'
        expect(transcript_rows[0][:probation]).to eq '3 years'

        expect(transcript_rows[1][:code_section]).to eq 'HS 55555'
        expect(transcript_rows[1][:prison]).to eq '2 years'

        expect(transcript_rows[2][:code_section]).to eq 'HS 11357'
        expect(transcript_rows[2][:prison]).to eq '2 years'
      end
    end
    context 'convictions in the same event have different sentences' do
      let(:text) do
        <<~TEXT
          info
          * * * *
          COURT:  NAM:02
          19880420 CASC SAN FRANCISCO CO
          CNT:01 #05378
            55555 HS-TRANSPORT/SELL

          DISPO:CONVICTED
            SEN: 1 YEAR PROBATION

          CNT:02 #05378
            11357 HS-POSSES

          DISPO:DISMISSED

          CNT:03 #05378
            11357 HS-POSSES

          DISPO:CONVICTED
            SEN: 2 YEARS PRISON
          * * * END OF MESSAGE * * *
        TEXT
      end
      it 'fills out the sentence attached to the count' do
        expect(transcript_rows.length).to eq 2

        expect(transcript_rows[0][:code_section]).to eq 'HS 55555'
        expect(transcript_rows[0][:prison]).to eq '-'
        expect(transcript_rows[0][:probation]).to eq '1 years'

        expect(transcript_rows[1][:code_section]).to eq 'HS 11357'
        expect(transcript_rows[1][:prison]).to eq '2 years'
        expect(transcript_rows[1][:probation]).to eq '-'
      end
    end
  end
end
