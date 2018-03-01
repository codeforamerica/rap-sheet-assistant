class Prop64PetitionCreator
  attr_reader :rap_sheet, :conviction_event

  def initialize(rap_sheet, conviction_event)
    @rap_sheet = rap_sheet
    @conviction_event = conviction_event
  end

  def create_petition
    user = rap_sheet.user
    pdf_fields = {
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => user.full_name,
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].Defendant_ft[0]' => user.full_name,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyStreet_ft[0]' => user.street_address,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyCity_ft[0]' => user.city,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyState_ft[0]' => user.state,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyZip_ft[0]' => user.zip_code,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Phone_ft[0]' => user.phone_number,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Email_ft[0]' => user.email,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'PRO-SE',
      'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => conviction_event.case_number,
      'topmostSubform[0].Page1[0].ExecutedDate_dt[0]' => Date.today.strftime('%m/%d/%Y'),
      'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[0].Checkbox[0]' => resentencing?,
      'topmostSubform[0].Page1[0].Caption_sf[0].DefendantInfo[0].#area[1].Checkbox[1]' => redesignation?,
      'topmostSubform[0].Page1[0].Checkbox[0]' => sentence_completed?,
      'topmostSubform[0].Page1[0].Checkbox[1]' => sentence_being_served?,
      'topmostSubform[0].Page1[0].Checkbox[2]' => count_possession?,
      'topmostSubform[0].Page1[0].Checkbox[3]' => count_cultivation?,
      'topmostSubform[0].Page1[0].Checkbox[4]' => count_possession_for_sale?,
      'topmostSubform[0].Page1[0].Checkbox[5]' => count_transportation?,
      'topmostSubform[0].Page1[0].Checkbox[6]' => count_personal_use?,
      'topmostSubform[0].Page1[0].Checkbox[7]' => 'Yes',
      'topmostSubform[0].Page1[0].Checkbox[8]' => 'Yes'
    }

    tempfile = Tempfile.new('filled-pdf')

    pdftk = PdfForms.new(Cliver.detect('pdftk'))

    pdftk.fill_form Rails.root.join('app', 'assets', 'petitions', 'prop64_petition.pdf'), tempfile.path, fields_for_pdftk(pdf_fields)

    tempfile
  end

  private

  def fields_for_pdftk(hsh)
    hsh.transform_values { |v| [true, false].include?(v) ? pdf_bool(v) : v }
  end

  def pdf_bool(value)
    if value
      'Yes'
    else
      'Off'
    end
  end

  def code_sections
    conviction_event.counts.map(&:code_section)
  end

  def resentencing?
    sentence_being_served?
  end

  def redesignation?
    sentence_completed?
  end

  def count_possession?
    code_sections.include?('HS 11357')
  end

  def count_cultivation?
    code_sections.include?('HS 11358')
  end

  def count_possession_for_sale?
    code_sections.include?('HS 11359')
  end

  def count_transportation?
    code_sections.include?('HS 11360')
  end

  def count_personal_use?
    code_sections.include?('HS 11362.1')
  end

  def sentence_being_served?
    end_of_sentence = conviction_event.date + conviction_event.sentence.total_duration
    end_of_sentence > Date.today
  end

  def sentence_completed?
    !sentence_being_served?
  end
end
