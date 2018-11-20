require 'rails_helper'

describe EligibilityChecker do
  let(:probation_dispo) { build_disposition(sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year), severity: 'M') }
  let(:prison_dispo) { build_disposition(sentence: RapSheetParser::ConvictionSentence.new(prison: 1.year), severity: 'F') }
  let(:prop64_eligible_count_1) { build_count(code: 'HS', section: '11357(b)', disposition: probation_dispo) }
  let(:prop64_eligible_count_2) { build_count(code: 'HS', section: '11357(a)', disposition: prison_dispo) }
  let(:pc1203_eligible_count) { build_count(code: 'PC', section: '456', disposition: probation_dispo) }
  let(:pc1203_ineligible_count) { build_count(code: 'PC', section: '456', disposition: prison_dispo) }

  describe '#all_eligible_counts' do
    it 'returns a hash with all counts split by remedy type' do
      user = User.create!(
        rap_sheet: RapSheet.new,
        on_parole: false,
        on_probation: false,
        outstanding_warrant: false
      )

      parsed_rap_sheet = build_rap_sheet(
        events: [
          build_court_event(
            counts: [prop64_eligible_count_1, pc1203_eligible_count],
            date: Date.today - 5.years
          ),
          build_court_event(
            counts: [prop64_eligible_count_2],
            date: Date.today - 5.years
          ),
          build_other_event(event_type: 'arrest', date: Date.today)
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

      parsed_rap_sheet = build_rap_sheet(
        events: [
          build_court_event(
            counts: [prop64_eligible_count_1, pc1203_eligible_count],
            date: Date.today - 5.years
          ),
          build_court_event(
            counts: [prop64_eligible_count_2],
            date: Date.today - 5.years
          ),
          build_other_event(event_type: 'arrest', date: Date.today)
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

      event_1 = build_court_event(
        date: Date.new(2014, 6, 1),
        counts: [prop64_eligible_count_1, pc1203_eligible_count]
      )
      event_2 = build_court_event(
        date: nil,
        counts: [prop64_eligible_count_2]
      )
      parsed_rap_sheet = build_rap_sheet(
        events: [event_1, event_2, build_other_event(event_type: 'arrest', date: Date.new(2015, 1, 1))]
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

      parsed_rap_sheet = build_rap_sheet(events: [])
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).needs_1203_info?).to eq false


      parsed_rap_sheet = build_rap_sheet(
        events: [
          build_court_event(
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

      parsed_rap_sheet = build_rap_sheet(
        events: [
          build_court_event(
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

      parsed_rap_sheet = build_rap_sheet
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).eligible?).to eq false


      parsed_rap_sheet = build_rap_sheet(
        events: [
          build_court_event(
            counts: [pc1203_ineligible_count]
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

      parsed_rap_sheet = build_rap_sheet(
        events: [
          build_court_event(
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

      parsed_rap_sheet = build_rap_sheet
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).potentially_eligible?).to eq false


      parsed_rap_sheet = build_rap_sheet(
        events: [
          build_court_event(
            counts: [pc1203_ineligible_count]
          )
        ]
      )
      allow(user.rap_sheet).to receive(:parsed).and_return(parsed_rap_sheet)

      expect(described_class.new(user).potentially_eligible?).to eq false
    end
  end
end
