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
      state_bar_number = "    State Bar No: #{attorney.state_bar_number}"
      firm = attorney.firm_name
    else
      contact_info_person = user
      client_name = 'PRO-SE'
      state_bar_number = ''
      firm = ''
    end

    pdf_fields = {
      'Field1' => "#{contact_info_person.name}#{state_bar_number}",
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

    conviction_counts.each_with_index do |count, index|
      pdf_fields.merge!(fields_for_count(count, index))
    end

    pdf_fields.merge!(PC1203RemedyCheckboxes.new(remedy_details).fields)

    fill_petition('pc1203_petition.pdf', pdf_fields)
  end

  private

  attr_reader :rap_sheet, :conviction_event, :conviction_counts, :remedy_details

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
    starting_field_number = 18 + (index*5)
    {
      "Field#{starting_field_number}" => count.code,
      "Field#{starting_field_number+1}" => count.section,
      "Field#{starting_field_number+2}" => long_severity(count),
      "Field#{starting_field_number+3}" => reducible_to_misdemeanor(count),
      "Field#{starting_field_number+4}" => reducible_to_infraction(count)
    }
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
