require 'spec_helper'
require 'rap_sheet_parser'

RSpec.describe ConvictionEvent do
  describe '#severity' do
    it 'returns the highest severity found within the counts' do
      event = build_event

      event.counts = [double(severity: 'F')]
      expect(event.severity).to eq 'F'

      event.counts = [double(severity: 'I'), double(severity: 'F')]
      expect(event.severity).to eq 'F'

      event.counts = [double(severity: 'I'), double(severity: 'M')]
      expect(event.severity).to eq 'M'

      event.counts = [double(severity: 'I'), double(severity: 'I')]
      expect(event.severity).to eq 'I'
    end
  end

  describe '#successfully_completed_probation?' do
    it 'returns false if any arrests or custody events within probation period' do
      conviction_event = build_event(
        sentence: ConvictionSentence.new(probation: 1.year),
        date: Date.new(1994,1,2)
      )
      arrest_event = ArrestEvent.new(date: Date.new(1994,6,2))
      events = EventCollection.new([conviction_event, arrest_event])

      expect(conviction_event.successfully_completed_probation?(events)).to eq false
    end

    it 'skips events without dates' do
      conviction_event = build_event(
        sentence: ConvictionSentence.new(probation: 1.year),
        date: Date.new(1994,1,2)
      )
      arrest_no_date_event = ArrestEvent.new(date: nil)
      events = EventCollection.new([conviction_event, arrest_no_date_event])

      expect(conviction_event.successfully_completed_probation?(events)).to eq true
    end

    it 'returns nil if event does not have a date' do
      conviction_event = build_event(
        sentence: ConvictionSentence.new(probation: 1.year),
        date: nil
      )
      arrest_no_date_event = ArrestEvent.new(date: nil)
      events = EventCollection.new([conviction_event, arrest_no_date_event])

      expect(conviction_event.successfully_completed_probation?(events)).to be_nil
    end
  end

  def build_event(date: nil, case_number: nil, courthouse: nil, sentence: nil)
    described_class.new(
      date: date,
      case_number: case_number,
      courthouse: courthouse,
      sentence: sentence
    )
  end
end
