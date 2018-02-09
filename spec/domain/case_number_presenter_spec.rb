require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/case_number_presenter'
require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'

describe CaseNumberPresenter do
  it 'strips whitespace from case numbers' do
    text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #45      6
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    case_number_node = tree.cycles[0].events[0].case_number

    expect(described_class.present(case_number_node)).to eq '456'
  end

  it 'strips trailing punctuation from case numbers' do
    text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #456.:
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    case_number_node = tree.cycles[0].events[0].case_number

    expect(described_class.present(case_number_node)).to eq '456'
  end

  it 'strips periods from case numbers' do
    text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001 #4.5.6
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    case_number_node = tree.cycles[0].events[0].case_number

    expect(described_class.present(case_number_node)).to eq '456'
  end

  it 'returns nil case number for an unknown count one' do
    text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19990909 CAMC L05 ANGELES METRO
        
        CNT: 002
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    case_number_node = tree.cycles[0].events[0].case_number

    expect(described_class.present(case_number_node)).to eq nil
  end

  it 'returns nil case number for an unknown case number' do
    text = <<~TEXT
        info
        * * * *
        COURT: NAME7OZ
        19820915 CAMC L05 ANGELES METRO
        
        CNT: 001
        garbled
        DISPO:CONVICTED
        * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    case_number_node = tree.cycles[0].events[0].case_number

    expect(described_class.present(case_number_node)).to eq nil
  end
end
