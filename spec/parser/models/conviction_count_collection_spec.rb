require 'rap_sheet_parser'

describe ConvictionCountCollection do
  describe '#events' do
    it 'returns all unique events from counts' do
      event_1 = double(:event)
      event_2 = double(:event)

      subject = described_class.new([
        build_conviction_count(event: event_1),
        build_conviction_count(event: event_2),
        build_conviction_count(event: event_1)
      ]).events

      expect(subject).to eq [event_1, event_2]
    end
  end

  describe 'severity filters' do
    it 'can filter counts by severity strings' do
      count_1 = build_conviction_count(severity: 'F')
      count_2 = build_conviction_count(severity: 'M')
      count_3 = build_conviction_count(severity: nil)

      subject = described_class.new([
        count_1, count_2, count_3
      ])

      expect(subject.severity_felony).to eq [count_1]
      expect(subject.severity_misdemeanor).to eq [count_2]
      expect(subject.severity_unknown).to eq [count_3]
    end
  end

  describe '#-' do
    it 'wraps the subtraction result as a ConvictionCountCollection' do
      count_1 = build_conviction_count
      count_2 = build_conviction_count

      subject = described_class.new([count_1, count_2]) - described_class.new([count_1])

      expect(subject).to eq described_class.new([count_2])
      expect(subject).to be_a described_class
    end
  end

  describe '#select' do
    it 'wraps the selection result as a ConvictionCountCollection' do
      count_1 = build_conviction_count(severity: 'F')
      count_2 = build_conviction_count

      subject = described_class.new([count_1, count_2]).select do |c|
        c.severity == 'F'
      end

      expect(subject).to eq described_class.new([count_1])
      expect(subject).to be_a described_class
    end
  end
end
