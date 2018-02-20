require 'spec_helper'

require_relative '../../app/domain/sentence_parser'

describe SentenceParser do
  it 'computes a duration from the sentence string' do
    expect(SentenceParser.parse('1y jail, fine')).to eq(1.year)
    expect(SentenceParser.parse('30d probation')).to eq(30.days)
    expect(SentenceParser.parse('1y jail, 6m probation')).to eq(1.year + 6.months)
  end
end
