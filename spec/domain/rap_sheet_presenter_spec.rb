require 'spec_helper'
require 'treetop'
require 'date'

Treetop.load 'app/parser/common_grammar'

require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'
require_relative '../../app/domain/conviction_count'
require_relative '../../app/domain/courthouse_presenter'
require_relative '../../app/domain/case_number_presenter'

require_relative '../../app/domain/rap_sheet_presenter'

describe RapSheetPresenter do
  describe '.present' do
    it 'only returns events with convictions' do
      text = <<~TEXT
        info
        * * * *
        ARREST
        blah
        - - - -        
        COURT:
        19740102 CASC SAN PRANCISCU rm
        
        CNT: 001 #123
        DISPO:DISMISSED/FURTHERANCE OF JUSTICE
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #456
        bla bla
        DISPO:CONVICTED

        CNT:002 
        bla bla
        DISPO:DISMISSED

        CNT:003
        4056 PC-BREAKING AND ENTERING
        *DISPO:CONVICTED
        MORE INFO ABOUT THIS COUNT
        * * * *
        COURT:
        19941120 CASC SAN DIEGO

        CNT: 001 #612
        487.2 PC-GRAND THEFT FROM PERSON
        DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        * * * END OF MESSAGE * * *
      TEXT

      tree = Parser.new.parse(text)
      events_with_convictions = described_class.present(tree)

      verify_event_looks_like(events_with_convictions[0], {
        date: Date.new(1982, 9, 15),
        case_number: '456',
        courthouse: 'CAMC L05 ANGELES METRO',
        sentence: nil,
      })
      verify_event_looks_like(events_with_convictions[1], {
        date: Date.new(1994, 11, 20),
        case_number: '612',
        courthouse: 'CASC SAN DIEGO',
        sentence: '12m probation, 45d jail'
      })

      verify_count_looks_like(events_with_convictions[0].counts[0], {
        code_section: nil,
        code_section_description: nil,
        severity: nil,
      })
      verify_count_looks_like(events_with_convictions[0].counts[1], {
        code_section: 'PC 4056',
        code_section_description: 'BREAKING AND ENTERING',
        severity: nil,
      })
      verify_count_looks_like(events_with_convictions[1].counts[0], {
        code_section: 'PC 487.2',
        code_section_description: 'GRAND THEFT FROM PERSON',
        severity: 'M',
      })
    end

    context 'inferring probation violations' do
      it 'annotates conviction counts that might have violated probation' do
        text = <<~TEXT
          info
          * * * *
          ARR/DET/CITE: NAM:02 DOB:19550505
          19840101  CASO LOS ANGELES
          
          CNT:01     #1111111
            496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
             COM: WARRANT NBR A-400000 BOTH CNTS
          
          - - - -
          
          COURT:                NAM:01
          19840918  CASC LOS ANGELES
          
          CNT:01     #1234567
            496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
          *DISPO:CONVICTED
             CONV STATUS:MISDEMEANOR
             SEN: 2 YEARS PRISON
          * * * END OF MESSAGE * * *
        TEXT
      end
    end
  end

  def verify_event_looks_like(event, date:, case_number:, courthouse:, sentence:)
    expect(event.date).to eq date
    expect(event.case_number).to eq case_number
    expect(event.courthouse).to eq courthouse
    expect(event.sentence.to_s).to eq sentence
  end

  def verify_count_looks_like(count, code_section:, code_section_description:, severity:)
    expect(count.code_section).to eq code_section
    expect(count.code_section_description).to eq code_section_description
    expect(count.severity).to eq severity
  end
end
