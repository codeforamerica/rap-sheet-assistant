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
      state_bar_number = attorney.state_bar_number
      firm = attorney.firm_name
    else
      contact_info_person = user
      client_name = 'PRO-SE'
      state_bar_number = ''
      firm = ''
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
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFirm_ft[0]' => firm,
      'topmostSubform[0].Page1[0].Checkbox[7]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[8]' => 'Yes',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyBarNo_dc[0]' => state_bar_number
    }

    pdf_fields.merge!(remedy_checkboxes)
    pdf_fields.merge!(scenario_checkboxes)

    proof_of_service_fields = {
      'name' =>contact_info_person.name,
      'state bar number' =>state_bar_number,
      'firm name' =>firm,
      'street address' =>contact_info_person.street_address,
      'city' =>contact_info_person.city,
      'state' =>contact_info_person.state,
      'zip' =>contact_info_person.zip,
      'phone number' =>contact_info_person.phone_number,
      'email' =>contact_info_person.email,
      'attorney for' =>client_name,
      'defendant' =>user.name,
      'case number' =>conviction_event.case_number,
      'proof_of_service_prop64' => true,
    }

    result = []
    result << fill_petition('prop64_petition.pdf', pdf_fields)
    result << fill_petition('proof_of_service.pdf', proof_of_service_fields)

    concatenate_pdfs(result)
  end

  private

  attr_reader :rap_sheet, :conviction_event, :conviction_counts, :remedy_details

  def concatenate_pdfs(pdfs)
    pdftk = PdfForms.new(Cliver.detect('pdftk'))
    Tempfile.new('concatenated-pdfs').tap do |tempfile|
      pdftk.cat(*pdfs, tempfile)
    end
  end

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
