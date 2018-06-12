require 'rails_helper'

describe EligibilityChecker do
  let(:prop64_eligible_count_1) { build_conviction_count(code: 'HS', section: '11357(b)') }
  let(:prop64_eligible_count_2) { build_conviction_count(code: 'HS', section: '11357(a)') }
  let(:pc1203_eligible_count) { build_conviction_count(code: 'PC', section: '456') }

  describe '#all_eligible_counts' do
    it 'returns a hash with all counts split by remedy type' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: false,
        on_probation: false,
        outstanding_warrant: false
      )

      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
            counts: [prop64_eligible_count_1, pc1203_eligible_count],
            date: Date.today - 5.years
          ),
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(prison: 1.year),
            counts: [prop64_eligible_count_2],
            date: Date.today - 5.years
          ),
          RapSheetParser::ArrestEvent.new(date: Date.today)
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).all_eligible_counts).to eq ({
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

      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
            counts: [prop64_eligible_count_1, pc1203_eligible_count],
            date: Date.today - 5.years
          ),
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(prison: 1.year),
            counts: [prop64_eligible_count_2],
            date: Date.today - 5.years
          ),
          RapSheetParser::ArrestEvent.new(date: Date.today)
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).all_potentially_eligible_counts).to eq ({
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
        date: Date.new(2014, 6, 1),
        sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
        counts: [prop64_eligible_count_1, pc1203_eligible_count]
      )
      event_2 = build_conviction_event(
        date: nil,
        sentence: RapSheetParser::ConvictionSentence.new(prison: 1.year),
        counts: [prop64_eligible_count_2]
      )
      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [event_1, event_2, RapSheetParser::ArrestEvent.new(date: Date.new(2015, 1, 1))]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).eligible_events_with_counts).to eq ([
        {
          event: event_1,
          prop64: {
            counts: [prop64_eligible_count_1],
            remedy: { codes: ['HS 11357'], scenario: :redesignation }
          },
          pc1203: {
            counts: [pc1203_eligible_count],
            remedy: { code: '1203.4', scenario: :discretionary }
          }
        },
        {
          event: event_2,
          prop64: {
            counts: [prop64_eligible_count_2],
            remedy: { codes: ['HS 11357'], scenario: :unknown }
          },
          pc1203: {
            counts: [],
            remedy: nil
          }
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

      parsed_rap_sheet = RapSheetParser::RapSheet.new([])
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).needs_1203_info?).to eq false


      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
            counts: [pc1203_eligible_count],
            date: Date.today - 5.years
          )
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).needs_1203_info?).to eq true
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

      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
            counts: [pc1203_eligible_count],
            date: Date.today - 5.years
          )
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).eligible?).to eq true
    end

    it 'returns false if there are no eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: true,
        on_probation: false,
        outstanding_warrant: false
      )

      parsed_rap_sheet = RapSheetParser::RapSheet.new([])
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).eligible?).to eq false


      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(prison: 1.year),
            counts: [pc1203_eligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).eligible?).to eq false
    end
  end

  describe '#potentially_eligible' do
    it 'returns true if there are any potentially eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
      )

      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
            counts: [pc1203_eligible_count],
            date: Date.today - 5.years
          )
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).potentially_eligible?).to eq true
    end

    it 'returns false if there are no potentially eligible counts' do
      user = User.create!(
        rap_sheet: RapSheet.new,
      )

      parsed_rap_sheet = RapSheetParser::RapSheet.new([])
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).potentially_eligible?).to eq false


      parsed_rap_sheet = RapSheetParser::RapSheet.new(
        [
          build_conviction_event(
            sentence: RapSheetParser::ConvictionSentence.new(prison: 1.year),
            counts: [pc1203_eligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).potentially_eligible?).to eq false
    end
  end
end

def build_conviction_count(code:, section:)
  RapSheetParser::ConvictionCount.new(
    event: double(:event),
    code_section_description: 'foo',
    severity: 'M',
    code: code,
    section: section)
end

def build_conviction_event(
  date: Date.new(1994, 1, 2),
  case_number: '12345',
  courthouse: 'CASC SAN FRANCISCO',
  sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
  counts: []
)

  event = RapSheetParser::ConvictionEvent.new(
    date: date, courthouse: courthouse, case_number: case_number, sentence: sentence)
  event.counts = counts
  event
end
