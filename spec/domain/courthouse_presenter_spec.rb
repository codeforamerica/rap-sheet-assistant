require 'spec_helper'

require 'treetop'

require_relative '../../app/domain/courthouse_presenter'
require_relative '../../app/parser/parser'
require_relative '../../app/helpers/text_cleaner'

describe CourthousePresenter do
  it 'translates courthouse names to display names' do
    text = <<~TEXT
      info
      * * * *
      COURT: NAME7OZ
      19820915 CASC SN JOSE

      CNT: 001 #45      6
      DISPO:CONVICTED
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    courthouse_node = tree.cycles[0].events[0].courthouse
    expect(described_class.present(courthouse_node)).to eq 'CASC San Jose'
  end

  it 'displays unknown courthouse names directly' do
    text = <<~TEXT
      info
      * * * *
      COURT: NAME7OZ
      19820915 CASC ANYTOWN USA

      CNT: 001 #45      6
      DISPO:CONVICTED
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    courthouse_node = tree.cycles[0].events[0].courthouse
    expect(described_class.present(courthouse_node)).to eq 'CASC ANYTOWN USA'
  end

  it 'strips periods from courthouse names' do
    text = <<~TEXT
      info
      * * * *
      COURT: NAME7OZ
      19820915 CAMC LOS .ANGELES METRO

      CNT: 001 #45      6
      DISPO:CONVICTED
      * * * END OF MESSAGE * * *
    TEXT

    tree = Parser.new.parse(text)
    courthouse_node = tree.cycles[0].events[0].courthouse
    expect(described_class.present(courthouse_node)).to eq 'CAMC Los Angeles Metro'
  end
end
