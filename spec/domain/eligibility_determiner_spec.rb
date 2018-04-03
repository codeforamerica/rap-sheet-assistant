require 'rails_helper'

describe EligibilityDeterminer do
  let(:prop64_eligible_count_1) { build_conviction_count(code: 'HS', section: '11357') }
  let(:prop64_eligible_count_2) { build_conviction_count(code: 'HS', section: '11357') }
  let(:pc1203_eligible_count) { build_conviction_count(code: 'PC', section: '456') }

  describe '#all_eligible_counts' do
    it 'returns a hash with all counts split by remedy type' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: false,
        on_probation: false,
        outstanding_warrant: false
      )

      events = EventCollection.new(
        [
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr probation'),
            counts: [prop64_eligible_count_1, pc1203_eligible_count]
          ),
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr prison'),
            counts: [prop64_eligible_count_2]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).all_eligible_counts).to eq ({
        prop64: [prop64_eligible_count_1, prop64_eligible_count_2],
        pc1203: [pc1203_eligible_count]
      })
    end
  end

  describe '#all_potentially_eligible_counts' do
    it 'returns a hash with all counts split by remedy type' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: true,
        on_probation: false,
        outstanding_warrant: false
      )

      events = EventCollection.new(
        [
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr probation'),
            counts: [prop64_eligible_count_1, pc1203_eligible_count]
          ),
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr prison'),
            counts: [prop64_eligible_count_2]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).all_potentially_eligible_counts).to eq ({
        prop64: [prop64_eligible_count_1, prop64_eligible_count_2],
        pc1203: [pc1203_eligible_count]
      })
    end
  end

  describe '#eligible_events_with_counts' do
    it 'returns a hash with all events and counts split by remedy type' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: false,
        on_probation: false,
        outstanding_warrant: false
      )

      event_1 = build_conviction_event(
        sentence: ConvictionSentence.new('1yr probation'),
        counts: [prop64_eligible_count_1, pc1203_eligible_count]
      )
      event_2 = build_conviction_event(
        sentence: ConvictionSentence.new('1yr prison'),
        counts: [prop64_eligible_count_2]
      )
      events = EventCollection.new([event_1, event_2])
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).eligible_events_with_counts).to eq ([
        {
          event: event_1,
          counts: { prop64: [prop64_eligible_count_1], pc1203: [pc1203_eligible_count]}
        },
        {
          event: event_2,
          counts: { prop64: [prop64_eligible_count_2], pc1203: []}
        }
      ])
    end
  end

  describe '#needs_1203_info?' do
    it 'returns true if there are potentially 1203 eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: true,
        on_probation: false,
        outstanding_warrant: false
      )

      events = EventCollection.new([])
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).needs_1203_info?).to eq false


      events = EventCollection.new(
        [
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr probation'),
            counts: [pc1203_eligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).needs_1203_info?).to eq true
    end
  end

  describe '#eligible' do
    it 'returns true if there are any eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: false,
        on_probation: false,
        outstanding_warrant: false
      )

      events = EventCollection.new(
        [
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr probation'),
            counts: [pc1203_eligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).eligible?).to eq true
    end

    it 'returns false if there are no eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: true,
        on_probation: false,
        outstanding_warrant: false
      )

      events = EventCollection.new([])
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).eligible?).to eq false


      events = EventCollection.new(
        [
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr prison'),
            counts: [pc1203_eligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).eligible?).to eq false
    end
  end

  describe '#potentially_eligible' do
    it 'returns true if there are any potentially eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
      )

      events = EventCollection.new(
        [
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr probation'),
            counts: [pc1203_eligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).potentially_eligible?).to eq true
    end

    it 'returns false if there are no potentially eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
      )

      events = EventCollection.new([])
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).potentially_eligible?).to eq false


      events = EventCollection.new(
        [
          build_conviction_event(
            sentence: ConvictionSentence.new('1yr prison'),
            counts: [pc1203_eligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:events).and_return(events)

      expect(EligibilityDeterminer.new(user).potentially_eligible?).to eq false
    end
  end

  def build_conviction_event(sentence: nil, counts: nil)
    event = ConvictionEvent.new(date: nil, case_number: nil, courthouse: nil, sentence: sentence)
    event.counts = counts
    event
  end

  def build_conviction_count(code: nil, section: nil)
    ConvictionCount.new(
      event: nil,
      code_section_description: nil,
      severity: nil,
      code: code,
      section: section
    )
  end
end