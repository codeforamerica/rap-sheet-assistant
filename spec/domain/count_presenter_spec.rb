require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/count_presenter'
require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'

describe CountPresenter do
  it 'returns hash representing count' do
    text = <<~TEXT
      info
      * * * *
      COURT: NAME7OZ
      19820915 CASC SN JOSE

      CNT: 001  #346477
        496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
      *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    count_node = tree.cycles[0].events[0].counts[0]

    expect(described_class.present(count_node)).to eq ({
      code_section: 'PC 496',
      code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
      severity: 'M'
    })
  end

  it 'returns blank fields when information not present' do
    text = <<~TEXT
      info
      * * * *
      COURT: NAME7OZ
      19820915 CASC SN JOSE

      CNT: 001  #346477
        DISPO:CONVICTED
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    count_node = tree.cycles[0].events[0].counts[0]

    expect(described_class.present(count_node)).to eq ({
      code_section: '',
      code_section_description: '',
      severity: ''
    })
  end

  it 'strips whitespace out of the code section number' do
    text = <<~TEXT
      info
      * * * *
      COURT: NAME7OZ
      19820915 CASC SN JOSE

      CNT: 001  #346477
        496 (A) (2) PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
      *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    count_node = tree.cycles[0].events[0].counts[0]

    expect(described_class.present(count_node)).to eq ({
      code_section: 'PC 496(A)(2)',
      code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
      severity: 'M'
    })
  end

  it 'replaces commas with periods in the code section number' do
    text = <<~TEXT
      info
      * * * *
      COURT: NAME7OZ
      19820915 CASC SN JOSE

      CNT: 001  #346477
        496,3(A)(2) PC-RECEIVE/ETC KNOWN STOLEN PROPERTY
      *DISPO:CONVICTED
        CONV STATUS:MISDEMEANOR
        SEN: 012 MONTHS PROBATION, 045 DAYS JAIL
        COM: SENTENCE CONCURRENT WITH FILE #743-2:
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    count_node = tree.cycles[0].events[0].counts[0]

    expect(described_class.present(count_node)).to eq ({
      code_section: 'PC 496.3(A)(2)',
      code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
      severity: 'M'
    })
  end
end
