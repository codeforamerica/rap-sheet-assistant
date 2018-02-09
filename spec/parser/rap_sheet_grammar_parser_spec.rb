require 'spec_helper'
require 'treetop'

require_relative '../../app/parser/rap_sheet_syntax_nodes'
require_relative '../../app/parser/cycle_syntax_nodes'

Treetop.load 'app/parser/common_grammar'
Treetop.load 'app/parser/rap_sheet_grammar'

RSpec.describe RapSheetGrammarParser do
  describe '#parse' do
    subject { described_class.new.parse(text) }

    context 'parsing one cycle' do
      let(:text) {
        <<~TEXT
          arbitrary text

          * * * *
          cycle text
          * * * END OF MESSAGE * * *
        TEXT
      }

      it 'parses cycle content' do
        expect(subject.cycles[0].cycle_content.text_value).to eq('cycle text')
      end
    end

    context 'parsing multiple cycles' do
      let(:text) {
        <<~TEXT
          super
          arbitrary

          * * * *
          cycle text
          * * * *
          another cycle text
          * * * END OF MESSAGE * * *
        TEXT
      }

      it 'has an events method that calls the cycle parser' do
        expect(subject.cycles[0].cycle_content.text_value).to eq('cycle text')
        expect(subject.cycles[1].cycle_content.text_value).to eq('another cycle text')
      end
    end

    it 'parses extra periods and commas in cycle delimiter' do
      text = <<~TEXT
        super
        arbitrary

          .   * *, * *.  
        cycle text
        .,* * * * .
        another cycle text
        * * * END OF MESSAGE * * *
      TEXT

      cycles = described_class.new.parse(text).cycles

      expect(cycles[0].cycle_content.text_value).to eq('cycle text')
      expect(cycles[1].cycle_content.text_value).to eq('another cycle text')
    end

    it 'allows for arbitrary number of asterisks before end of message' do
      text = <<~TEXT
        arbitrary

        * * * *
        cycle text
        * END OF MESSAGE.
        some stuff
      TEXT

      expect(described_class.new.parse(text)).not_to be_nil
    end

    describe 'parsing events from cycles' do
      let(:text) {
        <<~TEXT
          hello

          * * * *
          event 1
          - - - -
          event 2
          * * * *
          event 3
          - - - -
          event 4
          * * * END OF MESSAGE * * *
        TEXT
      }

      it 'has an events method that calls the cycle parser' do
        result = subject.cycles
        cycle1 = result[0]
        cycle2 = result[1]
        expect(cycle1.events[0].text_value).to eq 'event 1'
        expect(cycle1.events[1].text_value).to eq 'event 2'
        expect(cycle2.events[0].text_value).to eq 'event 3'
        expect(cycle2.events[1].text_value).to eq 'event 4'
      end
    end
  end
end