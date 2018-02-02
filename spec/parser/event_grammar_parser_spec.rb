require 'spec_helper'
require 'treetop'

require_relative '../../app/parser/event_syntax_nodes'

Treetop.load 'app/parser/event_grammar'

RSpec.describe EventGrammarParser do
  describe '#parse' do
    subject { described_class.new.parse(text) }

    context 'parsing a court event' do
      let(:text) {
        <<~TEXT
          COURT:
          20040102  SAN FRANCISCO

          CNT: 001  #346477
          blah
          DISPO:CONVICTED

          CNT: 002
          count 2 text
          DISPO:DISMISSED

          CNT: 003
          count 3 text
        TEXT
      }

      it 'parses a court event' do
        expect(subject).to be_a(EventGrammar::CourtEvent)
      end

      it 'identifies the date' do
        expect(subject.date.text_value).to eq('20040102')
        end

      it 'identifies the courthouse' do
        expect(subject.courthouse.text_value).to eq("SAN FRANCISCO\n\n")
      end

      it 'identifies the case number' do
        expect(subject.case_number.text_value).to eq('#346477')
      end

      it 'identifies count data' do
        count_1 = subject.counts[0]
        expect(count_1.disposition.text_value).to eq('DISPO:CONVICTED')
        count_2 = subject.counts[1]
        expect(count_2.disposition.text_value).to eq('DISPO:DISMISSED')
        count_3 = subject.counts[2]
        expect(count_3.disposition.text_value).to eq('')
      end
    end
  end
end
