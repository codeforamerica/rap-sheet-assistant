class PC1203PetitionCreator
  attr_reader :rap_sheet, :conviction_event

  def initialize(rap_sheet, conviction_counts)
    @rap_sheet = rap_sheet
    @conviction_event = conviction_counts.first.event
    @conviction_counts = conviction_counts
  end

  def create_petition
    user = rap_sheet.user
    pdf_fields = {
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => user.full_name,
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].Defendant_ft[0]' => user.full_name,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyStreet_ft[0]' => user.street_address,
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseName[0].DefendantDOB_dt[0]' => user.date_of_birth.strftime('%m/%d/%Y'),
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyCity_ft[0]' => user.city,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyState_ft[0]' => user.state,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyZip_ft[0]' => user.zip_code,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Phone_ft[0]' => user.phone_number,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].Email_ft[0]' => user.email,
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'PRO-SE',
      'topmostSubform[0].Page1[0].Caption_sf[0].CaseNumber[0].CaseNumber_ft[0]' => conviction_event.case_number,
      'topmostSubform[0].Page1[0].ConvictionDate_dt[0]' => conviction_event.date.strftime('%m/%d/%Y'),
      'topmostSubform[0].Page2[0].PxCaption_sf[0].Defendant_ft[0]' => user.full_name,
      'topmostSubform[0].Page2[0].PxCaption_sf[0].CaseNumber_ft[0]' => conviction_event.case_number,
      'topmostSubform[0].Page2[0].ExecutedDate_dt[0]' => Date.today.strftime('%m/%d/%Y'),
      'topmostSubform[0].Page2[0].T215[0]' => user.street_address,
      'topmostSubform[0].Page2[0].T217[0]' => user.city,
      'topmostSubform[0].Page2[0].T218[0]' => user.state,
      'topmostSubform[0].Page2[0].T219[0]' => user.zip_code,
    }

    @conviction_counts.each_with_index do |count, index|
      pdf_fields.merge!(fields_for_count(count, index + 1))      
    end

    tempfile = Tempfile.new('filled-pdf')

    pdftk = PdfForms.new(Cliver.detect('pdftk'))

    pdftk.fill_form Rails.root.join('app', 'assets', 'petitions', 'pc1203_petition.pdf'), tempfile.path, fields_for_pdftk(pdf_fields)

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
  
  def fields_for_count(count, index)
    {
      "topmostSubform[0].Page1[0].Code#{index}_ft[0]" => count.code,
      "topmostSubform[0].Page1[0].Section#{index}_ft[0]" => count.section,
      "topmostSubform[0].Page1[0].TypeOff#{index}_ft[0]" => count.long_severity,
      "topmostSubform[0].Page1[0].Reduce#{index}_ft[0]" => reducible_to_misdemeanor(count),
      "topmostSubform[0].Page1[0].Offense#{index}_ft[0]" => reducible_to_infraction(count)
    }
  end

  def reducible_to_misdemeanor(count)
    is_reducible = count.severity == 'F' && Constants::WOBBLERS.include?(count.code_section)
    is_reducible ? 'yes' : 'no'
  end

  def reducible_to_infraction(count)
    is_reducible = count.severity == 'M' && Constants::REDUCIBLE_TO_INFRACTION.include?(count.code_section)
    is_reducible ? 'yes' : 'no'
  end

  def determine_checkboxes(conviction_event)
    if conviction_event.sentence.contains? "PROBATION"
      "1203.4"
    elsif conviction_event.has_felony?
      "1203.41"
    else
      "1203.4a"
    end
  end
end
