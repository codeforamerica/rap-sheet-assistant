require 'spec_helper'
require 'treetop'

require_relative '../../app/parser/cycle_syntax_nodes'

Treetop.load 'app/parser/cycle_grammar'

RSpec.describe CycleGrammarParser do
  describe '#parse' do
    subject { described_class.new.parse(text) }

    context 'parsing one event' do
      let(:text) {
        <<~TEXT
          event one text
        TEXT
      }

      it 'parses one event' do
        events = subject.events
        expect(events[0].text_value).to eq "event one text\n"
      end
    end

    context 'parsing many events' do
      let(:text) {
        <<~TEXT
          event one text
          - - - -
          another event
          with multiple lines
          - - - -
          more events
        TEXT
      }

      it 'parses many events' do
        events = subject.events
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq "another event\nwith multiple lines"
        expect(events[2].text_value).to eq "more events\n"
      end
    end
  end
end
