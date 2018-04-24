require 'spec_helper'
require 'rap_sheet_parser'

RSpec.describe UpdateGrammarParser do
  describe '#parse' do
    it 'parses updates' do
      text = <<~TEXT
        DISPO:SENTENCE MODIFIED
        SEN: 001 MONTHS JAIL
      TEXT

      tree = parse(text)
      expect(tree).to be_a(UpdateGrammar::Update)
    end

    it 'parses updates with stray information before it' do
      text = <<~TEXT
        Page 3
        DISPO:SENTENCE MODIFIED
        SEN: 001 MONTHS JAIL
      TEXT

      tree = parse(text)
      expect(tree).to be_a(UpdateGrammar::Update)
    end
  end

  def parse(text)
    described_class.new.parse(text)
  end
end
