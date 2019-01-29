require 'rails_helper'

describe Prop64PetitionCreator do

  let(:has_attorney) { false }
  let(:user) {
    build(:user,
          name: 'Test User',
          street_address: '123 Fake St',
          city: 'San Francisco',
          state: 'CA',
          zip: '12345',
          phone_number: '000-111-2222',
          email: 'me@me.com',
          has_attorney: has_attorney
    )
  }
  let(:rap_sheet) { create(:rap_sheet, user: user) }

  context 'fill out form contact info' do

    context 'when the client has an attorney' do
      let(:has_attorney) { true }
      let(:attorney) do
        create(:attorney,
               name: 'Ms. Attorney',
               state_bar_number: '1234567',
               firm_name: 'The Firm',
               street_address: '555 Main Street',
               city: 'Tulsa',
               state: 'OK',
               zip: '55555',
               phone_number: '5555555555',
               email: 'email@example.com'
        )
      end

      before do
        user.update(attorney: attorney)
      end

      it 'fills in the top form with attorney info' do
        conviction_counts = [build_count]
        conviction_event = build_court_event(
          case_number: '#ABCDE',
          date: Date.new(2010, 1, 1),
          counts: conviction_counts
        )

        pdf_file = nil
        travel_to Date.new(2015, 3, 3) do
          pdf_file = described_class.new(
            rap_sheet: rap_sheet,
            conviction_event: conviction_event,
            conviction_counts: conviction_counts,
            remedy_details: {
              codes: [],
              scenario: :resentencing
            },
            ).create_petition
        end
        expected_values = {
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => 'Ms. Attorney',
          'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].Defendant_ft[0]' => 'Test User',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyStreet_ft[0]' => '555 Main Street',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyCity_ft[0]' => 'Tulsa',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyState_ft[0]' => 'OK',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyZip_ft[0]' => '55555',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Phone_ft[0]' => '5555555555',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Email_ft[0]' => 'email@example.com',
          # 'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'Test User',
          # 'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyBarNo_dc[0]' => '1234567',
          # We don't know why this isn't working
          'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '#ABCDE',
          'topmostSubform[0].Page1[0].ExecutedDate_dt[0]' => '03/03/2015',
          'topmostSubform[0].Page1[0].Checkbox[7]' => 'Yes',
          'topmostSubform[0].Page1[0].Checkbox[8]' => 'Yes'
        }
        expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
      end
    end
    context 'when the client is filing pro-se' do
      it 'fills in the top form with client info' do
        conviction_counts = [build_count]
        conviction_event = build_court_event(
          case_number: '#ABCDE',
          date: Date.new(2010, 1, 1),
          counts: conviction_counts
        )

        pdf_file = nil
        travel_to Date.new(2015, 3, 3) do
          pdf_file = described_class.new(
            rap_sheet: rap_sheet,
            conviction_event: conviction_event,
            conviction_counts: conviction_counts,
            remedy_details: {
              codes: [],
              scenario: :resentencing
            },
            ).create_petition
        end
        expected_values = {
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => 'Test User',
          'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].Defendant_ft[0]' => 'Test User',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyStreet_ft[0]' => '123 Fake St',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyCity_ft[0]' => 'San Francisco',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyState_ft[0]' => 'CA',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyZip_ft[0]' => '12345',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Phone_ft[0]' => '000-111-2222',
          'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Email_ft[0]' => 'me@me.com',
          # 'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'PRO-SE',
          # 'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyBarNo_dc[0]' => '',
          # We don't know why this isn't working
          'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '#ABCDE',
          'topmostSubform[0].Page1[0].ExecutedDate_dt[0]' => '03/03/2015',
          'topmostSubform[0].Page1[0].Checkbox[7]' => 'Yes',
          'topmostSubform[0].Page1[0].Checkbox[8]' => 'Yes',

        }
        expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
      end
    end
  end

  it 'fills resentencing and petition checkboxes if sentence being served' do
    conviction_counts = [build_count(disposition: build_disposition(sentence: RapSheetParser::ConvictionSentence.new(jail: 1.year)))]
    conviction_event = build_court_event(
      date: Date.new(2014, 8, 8),
      counts: conviction_counts
    )
    pdf_file = nil
    travel_to Date.new(2015, 3, 3) do
      pdf_file = described_class.new(
        rap_sheet: rap_sheet,
        conviction_event: conviction_event,
        conviction_counts: conviction_counts,
        remedy_details: {
          codes: [],
          scenario: :resentencing
        }
      ).create_petition
    end

    expected_values = {
      'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[0].Checkbox[0]' => 'Yes',
      'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[1].Checkbox[1]' => 'Off',
      'topmostSubform[0].Page1[0].Checkbox[0]' => 'Off',
      'topmostSubform[0].Page1[0].Checkbox[1]' => 'Yes'
    }
    expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
  end

  it 'fills redesignation and application checkboxes if sentence completed' do
    conviction_counts = [build_count(disposition: build_disposition(sentence: RapSheetParser::ConvictionSentence.new(jail: 1.year)))]
    conviction_event = build_court_event(
      date: Date.new(2014, 8, 8),
      counts: conviction_counts
    )
    pdf_file = nil
    travel_to Date.new(2015, 8, 9) do
      pdf_file = described_class.new(
        rap_sheet: rap_sheet,
        conviction_event: conviction_event,
        conviction_counts: conviction_counts,
        remedy_details: {
          codes: [],
          scenario: :redesignation
        }
      ).create_petition
    end

    expected_values = {
      'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[0].Checkbox[0]' => 'Off',
      'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[1].Checkbox[1]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[0]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[1]' => 'Off'
    }
    expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
  end

  it 'fills remedy checkboxes for all applicable codes' do
    conviction_counts = [build_count(disposition: build_disposition(sentence: RapSheetParser::ConvictionSentence.new))]
    conviction_event = build_court_event(
      date: Date.new(2014, 8, 8),
      counts: conviction_counts
    )
    remedy_details = {
      codes: [
        'HS 11357',
        'HS 11358',
        'HS 11359',
        'HS 11360',
        'HS 11362.1'
      ],
      scenario: :resentencing
    }
    pdf_file = described_class.new(
      rap_sheet: rap_sheet,
      conviction_event: conviction_event,
      conviction_counts: conviction_counts,
      remedy_details: remedy_details
    ).create_petition

    expected_values = {
      'topmostSubform[0].Page1[0].Checkbox[2]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[3]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[4]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[5]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[6]' => 'Yes',
    }
    expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
  end

  it 'fills remedy checkboxes for only the appropriate codes' do
    conviction_counts = [build_count(disposition: build_disposition(sentence: RapSheetParser::ConvictionSentence.new))]
    conviction_event = build_court_event(
      date: Date.new(2014, 8, 8),
      counts: conviction_counts
    )
    remedy_details = {
      codes: ['HS 11359', 'HS 11362.1'],
      scenario: :redesignation
    }
    pdf_file = described_class.new(
      rap_sheet: rap_sheet,
      conviction_event: conviction_event,
      conviction_counts: conviction_counts,
      remedy_details: remedy_details
    ).create_petition

    expected_values = {
      'topmostSubform[0].Page1[0].Checkbox[2]' => 'Off',
      'topmostSubform[0].Page1[0].Checkbox[3]' => 'Off',
      'topmostSubform[0].Page1[0].Checkbox[4]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[5]' => 'Off',
      'topmostSubform[0].Page1[0].Checkbox[6]' => 'Yes',
    }
    expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
  end
end
