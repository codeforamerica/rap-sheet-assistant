require 'spec_helper'
require 'rap_sheet_parser'

describe SentenceGrammarParser do
  describe '#parse' do
    it 'parses sentence parts' do
      text = '012 MONTHS PROBATION, 045 DAYS JAIL, FINE SS, ANOTHER ONE'

      sentence = described_class.new.parse(text)

      expect(sentence.probation.text_value).to eq '012 MONTHS PROBATION'
      expect(sentence.jail.text_value).to eq '045 DAYS JAIL'
      expect(sentence.details[0].text_value).to eq 'FINE SS'
      expect(sentence.details[1].text_value).to eq 'ANOTHER ONE'
    end
  end
end

