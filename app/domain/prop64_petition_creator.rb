class Prop64PetitionCreator
  include PetitionCreator

  def initialize(rap_sheet:, conviction_event:, conviction_counts:, remedy_details:)
    @rap_sheet = rap_sheet
    @conviction_event = conviction_event
    @conviction_counts = conviction_counts
    @remedy_details = remedy_details
  end

  def create_petition
    user = rap_sheet.user
    if user.has_attorney
      attorney = user.attorney
      contact_info_person = attorney
      client_name = user.name
      state_bar_number = "#{attorney.state_bar_number}"
    else
      contact_info_person = user
      client_name = 'PRO-SE'
      state_bar_number = ''
    end
    pdf_fields = {
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => contact_info_person.name,
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].Defendant_ft[0]' => user.name,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyStreet_ft[0]' => contact_info_person.street_address,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyCity_ft[0]' => contact_info_person.city,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyState_ft[0]' => contact_info_person.state,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyZip_ft[0]' => contact_info_person.zip,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Phone_ft[0]' => contact_info_person.phone_number,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Email_ft[0]' => contact_info_person.email,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => client_name,
      'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => conviction_event.case_number,
      'topmostSubform[0].Page1[0].ExecutedDate_dt[0]' => Date.today.strftime('%m/%d/%Y'),
      'topmostSubform[0].Page1[0].Checkbox[7]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[8]' => 'Yes',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyBarNo_dc[0]' => state_bar_number
    }

    pdf_fields.merge!(remedy_checkboxes)
    pdf_fields.merge!(scenario_checkboxes)

    fill_petition('prop64_petition.pdf', pdf_fields)
  end

  private

  attr_reader :rap_sheet, :conviction_event, :conviction_counts, :remedy_details

  def code_sections
    conviction_counts.map(&:code_section)
  end

  def remedy_checkboxes
    checkboxes = {
      'HS 11357' => 'topmostSubform[0].Page1[0].Checkbox[2]',
      'HS 11358' => 'topmostSubform[0].Page1[0].Checkbox[3]',
      'HS 11359' => 'topmostSubform[0].Page1[0].Checkbox[4]',
      'HS 11360' => 'topmostSubform[0].Page1[0].Checkbox[5]',
      'HS 11362.1' => 'topmostSubform[0].Page1[0].Checkbox[6]',
    }

    remedy_details[:codes].map { |r| [checkboxes[r], 'Yes'] }.to_h
  end

  def scenario_checkboxes
    scenario_checkboxes = {
      resentencing: 'topmostSubform[0].Page1[0].Checkbox[1]',
      redesignation: 'topmostSubform[0].Page1[0].Checkbox[0]'
    }

    request_checkboxes = {
      resentencing: 'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[0].Checkbox[0]',
      redesignation: 'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[1].Checkbox[1]'
    }

    {
      scenario_checkboxes[remedy_details[:scenario]] => 'Yes',
      request_checkboxes[remedy_details[:scenario]] => 'Yes'
    }
  end
end
