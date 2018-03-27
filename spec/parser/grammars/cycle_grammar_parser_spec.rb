require 'spec_helper'
require 'rap_sheet_parser'

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

    context 'when the cycle delimiters have extra dashes' do
      let(:text) {
        <<~TEXT
          event one text
          - - -- --
          another event
          --- - ---
          more events
        TEXT
      }

      it 'parses many events' do
        events = subject.events
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq 'another event'
        expect(events[2].text_value).to eq "more events\n"
      end
    end

    context 'when court event has missing event delimiter' do
      let(:text) {
        <<~TEXT
          event one text
          COURT:
          another event
          --- - ---
          more events
        TEXT
      }

      it 'parses many events' do
        events = subject.events
        expect(events[0].text_value).to eq 'event one text'
        expect(events[1].text_value).to eq "COURT:\nanother event"
        expect(events[2].text_value).to eq "more events\n"
      end
    end

    it 'handles when court event has extra whitespace' do
      text = <<~TEXT
        event one text
        COURT :
        another event
        --- - ---
        more events
      TEXT

      events = described_class.new.parse(text).events
      expect(events[0].text_value).to eq 'event one text'
      expect(events[1].text_value).to eq "COURT :\nanother event"
      expect(events[2].text_value).to eq "more events\n"
      end

    it 'handles stray dashes in event' do
      text = <<~TEXT
        event
        -
        one text
        - - -- --
        another event
      TEXT

      events = described_class.new.parse(text).events
      expect(events.length).to eq 2
      expect(events[0].text_value).to eq "event\n-\none text"
      expect(events[1].text_value).to eq "another event\n"
    end
  end
end
