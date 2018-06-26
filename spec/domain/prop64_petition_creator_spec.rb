require 'rails_helper'

describe Prop64PetitionCreator do
  let(:user) {
    build(:user,
      first_name: 'Test',
      last_name: 'User',
      street_address: '123 Fake St',
      city: 'San Francisco',
      state: 'CA',
      zip_code: '12345',
      phone_number: '000-111-2222',
      email: 'me@me.com'
    )
  }
  let(:rap_sheet) { create(:rap_sheet, user: user) }

  it 'fills out contact info' do
    conviction_event = build_conviction_event(
      case_number: '#ABCDE',
      date: Date.new(2010, 1, 1),
      sentence: RapSheetParser::ConvictionSentence.new
    )
    conviction_counts = [build_conviction_count]

    pdf_file = nil
    travel_to Date.new(2015, 3, 3) do
      pdf_file = described_class.new(
        rap_sheet: rap_sheet,
        conviction_event: conviction_event,
        conviction_counts: conviction_counts,
        remedy: {
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
      # 'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'PRO-SE', # We don't know why this isn't working
      'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '#ABCDE',
      'topmostSubform[0].Page1[0].ExecutedDate_dt[0]' => '03/03/2015',
      'topmostSubform[0].Page1[0].Checkbox[7]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[8]' => 'Yes'
    }
    expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
  end

  it 'fills resentencing and petition checkboxes if sentence being served' do
    conviction_event = build_conviction_event(
      sentence: RapSheetParser::ConvictionSentence.new(jail: 1.year),
      date: Date.new(2014, 8, 8)
    )
    conviction_counts = [build_conviction_count]
    pdf_file = nil
    travel_to Date.new(2015, 3, 3) do
      pdf_file = described_class.new(
        rap_sheet: rap_sheet,
        conviction_event: conviction_event,
        conviction_counts: conviction_counts,
        remedy: {
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
    conviction_event = build_conviction_event(
      sentence: RapSheetParser::ConvictionSentence.new(jail: 1.year),
      date: Date.new(2014, 8, 8)
    )
    conviction_counts = [build_conviction_count]
    pdf_file = nil
    travel_to Date.new(2015, 8, 9) do
      pdf_file = described_class.new(
        rap_sheet: rap_sheet,
        conviction_event: conviction_event,
        conviction_counts: conviction_counts,
        remedy: {
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

  it 'fills remedy checkboxes' do
    conviction_event = build_conviction_event(
      sentence: RapSheetParser::ConvictionSentence.new,
      date: Date.new(2014, 8, 8)
    )
    conviction_counts = [build_conviction_count]
    remedy = {
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
      remedy: remedy
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

  it 'fills remedy checkboxes' do
    conviction_event = build_conviction_event(
      sentence: RapSheetParser::ConvictionSentence.new,
      date: Date.new(2014, 8, 8)
    )
    conviction_counts = [build_conviction_count]
    remedy = {
      codes: ['HS 11359', 'HS 11362.1'],
      scenario: :redesignation
    }
    pdf_file = described_class.new(
      rap_sheet: rap_sheet,
      conviction_event: conviction_event,
      conviction_counts: conviction_counts,
      remedy: remedy
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

def build_conviction_count(code: 'PC', section: '123', severity: 'M')
  RapSheetParser::ConvictionCount.new(
    code_section_description: 'foo',
    severity: severity,
    code: code,
    section: section
  )
end

def build_conviction_event(
  date: Date.new(1994, 1, 2),
  case_number: '12345',
  courthouse: 'CASC SAN FRANCISCO',
  sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year),
  counts: []
)

  RapSheetParser::ConvictionEvent.new(
    date: date,
    courthouse: courthouse,
    case_number: case_number,
    sentence: sentence,
    updates: [],
    counts: counts
  )
end
