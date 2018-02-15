require 'spec_helper'
require 'treetop'
require 'date'

Treetop.load 'app/parser/common_grammar'

require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'
require_relative '../../app/domain/count_presenter'
require_relative '../../app/domain/courthouse_presenter'
require_relative '../../app/domain/case_number_presenter'
require_relative '../../app/domain/sentence_presenter'

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

      expected_convictions = {
        events_with_convictions: [
          {
            counts: [
              {
                code_section: nil,
                code_section_description: nil,
                severity: nil,
              },
              {
                code_section: 'PC 4056',
                code_section_description: 'BREAKING AND ENTERING',
                severity: nil,
              }
            ],
            date: Date.new(1982, 9, 15),
            case_number: '456',
            courthouse: 'CAMC L05 ANGELES METRO',
            sentence: nil
          },
          {
            counts: [
              {
                code_section: 'PC 487.2',
                code_section_description: 'GRAND THEFT FROM PERSON',
                severity: 'M',
              }
            ],
            date: Date.new(1994, 11, 20),
            case_number: '612',
            courthouse: 'CASC SAN DIEGO',
            sentence: '12m probation, 45d jail'
          }
        ],
        conviction_counts: [
          {
            code_section: nil,
            code_section_description: nil,
            severity: nil,
          },
          {
            code_section: 'PC 4056',
            code_section_description: 'BREAKING AND ENTERING',
            severity: nil,
          },
          {
            code_section: 'PC 487.2',
            code_section_description: 'GRAND THEFT FROM PERSON',
            severity: 'M',
          }
        ]
      }

      tree = Parser.new.parse(text)
      expect(described_class.present(tree)).to eq expected_convictions
    end
  end

end
