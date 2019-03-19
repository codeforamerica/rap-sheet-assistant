class PC1203PetitionCreator
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
      if attorney.name.empty? || attorney.state_bar_number.empty?
        name_and_bar_num = ''
        state_bar_number = ''
      else
        name_and_bar_num = "#{attorney.name}    State Bar No: #{attorney.state_bar_number}"
      end
    else
      contact_info_person = user
      client_name = 'PRO-SE'
      state_bar_number = ''
      firm = ''
      name_and_bar_num = "#{contact_info_person.name}"
    end

    pdf_fields = {
      'Field1' => name_and_bar_num,
      'Field2' => firm,
      'Field3' => contact_info_person.street_address,
      'Field4' => contact_info_person.city,
      'Field5' => contact_info_person.state,
      'Field6' => contact_info_person.zip,
      'Field7' => contact_info_person.phone_number,
      'Field9' => contact_info_person.email,
      'Field10' => client_name,
      'Field11' => user.name,
      'Field12' => nil_checked_date(user.date_of_birth),
      'Field13' => conviction_event.case_number,
      'Field17' => conviction_event.date.strftime('%m/%d/%Y'),
      'Field49' => user.name,
      'Field50' => conviction_event.case_number,
      'Field62' => user.name,
      'Field63' => conviction_event.case_number,
      'Field72' => Date.today.strftime('%m/%d/%Y'),
      'Field74' => user.street_address,
      'Field75' => "#{user.city}, #{user.state}  #{user.zip}",
    }

    cr_181_fields = {
      'NAMEOFDEFENDANT' => client_name,
      'SBN' => state_bar_number,
      'FIRMNAME' => firm,
      'STREETADDRESS' => contact_info_person.street_address,
      'CITY' => contact_info_person.city,
      'STATE' => contact_info_person.state,
      'ZIPCODE' => contact_info_person.zip,
      'TELNO' => contact_info_person.phone_number,
      'DOB' => nil_checked_date(user.date_of_birth),
      'CASENO' => conviction_event.case_number
    }

    conviction_counts[0..4].each_with_index do |count, index|
      pdf_fields.merge!(fields_for_count(count, index))
    end

    if conviction_counts.length > 5
      mc_025_fields = mc_025_form(conviction_counts[5..-1])
    end

    pdf_fields.merge!(PC1203RemedyCheckboxes.new(remedy_details).fields)

    result = [fill_petition('pc1203_petition.pdf', pdf_fields), fill_petition('cr_181_form.pdf', cr_181_fields)]

    if conviction_counts.length > 5
      result << fill_petition('mc_025_for_pc1203_form.pdf', mc_025_fields)
    end

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

  def nil_checked_date(date)
    if date.nil?
      return ''
    end
    date.strftime('%m/%d/%Y')
  end

  def fields_for_count(count, index)
    starting_field_number = 18 + (index * 5)
    {
      "Field#{starting_field_number}" => count.code,
      "Field#{starting_field_number + 1}" => count.section,
      "Field#{starting_field_number + 2}" => long_severity(count),
      "Field#{starting_field_number + 3}" => reducible_to_misdemeanor(count),
      "Field#{starting_field_number + 4}" => reducible_to_infraction(count)
    }
  end

  def mc_025_form(counts)
    form = {
      'SHORT TITLE' => 'Attachment to CR-180',
      'CASE NUMBER' => conviction_event.case_number,
      'ATTACHMENT NUMBER' => '1',
      'PAGE' => '1',
      'OF TOTAL PAGES' => '1',
      'CODE' => 'Code',
      'SECTION' => 'Section',
      'OFFENSE_TYPE' => 'Type of Offense',
      'REDUCE_TO_MISDEMEANOR' => 'Reduction to misd: PC 17(b)',
      'REDUCE_TO_INFRACTION' => 'Reduction to infr: PC 17(d)(2)'
    }

    counts.each_with_index do |count, index|
      mc_025_body = {
        "CODE_#{index}" => count.code,
        "SECTION_#{index}" => count.section,
        "OFFENSE_#{index}" => long_severity(count),
        "MISD_#{index}" => reducible_to_misdemeanor(count),
        "INFR_#{index}" => reducible_to_infraction(count)
      }
      form.merge!(mc_025_body)
    end
    form
  end

  def reducible_to_misdemeanor(count)
    is_reducible = count.disposition.severity == 'F' && Constants::WOBBLERS.include?(count.code_section)
    is_reducible ? 'yes' : 'no'
  end

  def reducible_to_infraction(count)
    is_reducible = count.disposition.severity == 'M' && Constants::REDUCIBLE_TO_INFRACTION.include?(count.code_section)
    is_reducible ? 'yes' : 'no'
  end

  def long_severity(count)
    { 'F' => 'felony', 'M' => 'misdemeanor', 'I' => 'infraction' }[count.disposition.severity]
  end
end
