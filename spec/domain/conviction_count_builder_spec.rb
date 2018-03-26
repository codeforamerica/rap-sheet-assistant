require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/conviction_count'
require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'

describe ConvictionCountBuilder do
  let(:event) { { some: 'event' } }

  it 'populates values representing count' do
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

    subject = described_class.new(event, count_node).build
    expect(subject.code_section).to eq 'PC 496'
    expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
    expect(subject.severity).to eq 'M'
  end

  it 'returns nil fields when information not present' do
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

    subject = described_class.new(event, count_node).build
    expect(subject.code_section).to be_nil
    expect(subject.code_section_description).to be_nil
    expect(subject.severity).to be_nil
  end

  it 'strips whitespace out of the code section number and downcases letters' do
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

    subject = described_class.new(event, count_node).build
    expect(subject.code_section).to eq 'PC 496(a)(2)'
    expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
    expect(subject.severity).to eq 'M'
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
    subject = described_class.new(event, count_node).build
    expect(subject.code_section).to eq 'PC 496.3(a)(2)'
    expect(subject.code_section_description).to eq 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
    expect(subject.severity).to eq 'M'
  end
end
