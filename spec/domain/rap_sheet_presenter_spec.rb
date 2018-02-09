require 'spec_helper'
require 'treetop'
require 'date'

require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'
require_relative '../../app/domain/count_presenter'
require_relative '../../app/domain/courthouse_presenter'
require_relative '../../app/domain/case_number_presenter'

require_relative '../../app/domain/rap_sheet_presenter'

describe RapSheetPresenter do
  describe '.present' do
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
        bla bla
        DISPO:CONVICTED

        CNT:002 
        bla bla
        DISPO:DISMISSED

        CNT:003
        4056 PC-BREAKING AND ENTERING
        *DISPO:CONVICTED
        MORE INFO ABOUT THIS COUNT
        * * * END OF MESSAGE * * *
      TEXT

      expected_convictions = [
        {
          date: Date.new(1982, 9, 15),
          case_number: '456',
          courthouse: 'CAMC L05 ANGELES METRO',
          counts: [
            {
              penal_code: '',
              penal_code_description: ''
            },
            {
              penal_code: 'PC 4056',
              penal_code_description: 'BREAKING AND ENTERING'
            }
          ]
        }
      ]

      tree = Parser.new.parse(text)
      expect(described_class.present(tree)[:convictions]).to eq expected_convictions
    end
  end

end
