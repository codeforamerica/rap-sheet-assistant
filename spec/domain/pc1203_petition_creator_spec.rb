require 'rails_helper'

RSpec.describe PC1203PetitionCreator do
  let(:user) do
    build(:user,
      name: 'Test User',
      date_of_birth: Date.parse('1970-01-01'),
      street_address: '123 Fake St',
      city: 'San Francisco',
      state: 'CA',
      zip: '12345',
      phone_number: '000-111-2222',
      email: 'me@me.com'
    )
  end
  let(:rap_sheet) { create(:rap_sheet, user: user) }

  it 'creates a filled-out form with the users contact info' do
    conviction_counts = [
      build_count(
        disposition: build_disposition(sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year), severity: 'F'),
        code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
        code: 'PC',
        section: '111'
      )
    ]
    conviction_event = build_court_event(
      case_number: '#ABCDE',
      date: Date.new(2010, 1, 1),
      courthouse: 'CASC SAN FRANCISCO',
      counts: conviction_counts
    )
    remedy_details = { code: '1203.41' }

    pdf_file = PC1203PetitionCreator.new(
      rap_sheet: rap_sheet,
      conviction_event: conviction_event,
      conviction_counts: conviction_counts,
      remedy_details: remedy_details
    ).create_petition
    expected_values = {
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => 'Test User',
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].Defendant_ft[0]' => 'Test User',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyStreet_ft[0]' => '123 Fake St',
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].DefendantDOB_dt[0]' => '01/01/1970',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyCity_ft[0]' => 'San Francisco',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyState_ft[0]' => 'CA',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyZip_ft[0]' => '12345',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Phone_ft[0]' => '000-111-2222',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Email_ft[0]' => 'me@me.com',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'PRO-SE',
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseNumber[0].CaseNumber_ft[0]' => '#ABCDE',
      'topmostSubform[0].Page1[0].ConvictionDate_dt[0]' => '01/01/2010',
      'topmostSubform[0].Page2[0].OffenseWSentence_cb[1]' => '1'
    }
    expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
  end

  it 'fills out the offenses table with data from each count' do
    sentence = RapSheetParser::ConvictionSentence.new(probation: nil)
    conviction_counts = [
      build_count(
        disposition: build_disposition(sentence: sentence, severity: 'F'),
        code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
        code: 'PC',
        section: '107' # wobbler, felony
      ),
      build_count(
        disposition: build_disposition(sentence: sentence, severity: 'M'),
        code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
        code: 'PC',
        section: '12355(b)' # wobbler but already misdemeanor
      ),
      build_count(
        disposition: build_disposition(sentence: sentence, severity: 'F'),
        code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
        code: 'PC',
        section: '605' # made up (not a wobbler)
      ),
      build_count(
        disposition: build_disposition(sentence: sentence, severity: 'M'),
        code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
        code: 'PC',
        section: '330' # reducible to infraction
      )
    ]
    conviction_event = build_court_event(
      case_number: '#ABCDE',
      date: Date.parse('2010-01-01'),
      counts: conviction_counts
    )

    pdf_file = PC1203PetitionCreator.new(
      rap_sheet: rap_sheet,
      conviction_event: conviction_event,
      conviction_counts: conviction_counts,
      remedy_details: nil
    ).create_petition
    expected_values = {
      'topmostSubform[0].Page1[0].Code1_ft[0]' => 'PC',
      'topmostSubform[0].Page1[0].Section1_ft[0]' => '107',
      'topmostSubform[0].Page1[0].TypeOff1_ft[0]' => 'felony',
      'topmostSubform[0].Page1[0].Reduce1_ft[0]' => 'yes',
      'topmostSubform[0].Page1[0].Offense1_ft[0]' => 'no',

      'topmostSubform[0].Page1[0].Code2_ft[0]' => 'PC',
      'topmostSubform[0].Page1[0].Section2_ft[0]' => '12355(b)',
      'topmostSubform[0].Page1[0].TypeOff2_ft[0]' => 'misdemeanor',
      'topmostSubform[0].Page1[0].Reduce2_ft[0]' => 'no',
      'topmostSubform[0].Page1[0].Offense2_ft[0]' => 'no',

      'topmostSubform[0].Page1[0].Code3_ft[0]' => 'PC',
      'topmostSubform[0].Page1[0].Section3_ft[0]' => '605',
      'topmostSubform[0].Page1[0].TypeOff3_ft[0]' => 'felony',
      'topmostSubform[0].Page1[0].Reduce3_ft[0]' => 'no',
      'topmostSubform[0].Page1[0].Offense3_ft[0]' => 'no',

      'topmostSubform[0].Page1[0].Code4_ft[0]' => 'PC',
      'topmostSubform[0].Page1[0].Section4_ft[0]' => '330',
      'topmostSubform[0].Page1[0].TypeOff4_ft[0]' => 'misdemeanor',
      'topmostSubform[0].Page1[0].Reduce4_ft[0]' => 'no',
      'topmostSubform[0].Page1[0].Offense4_ft[0]' => 'yes'
    }

    expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
  end
end
