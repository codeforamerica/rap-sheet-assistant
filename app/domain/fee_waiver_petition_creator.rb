class FeeWaiverPetitionCreator
  include PetitionCreator

  def initialize(user)
    @user = user
  end

  def create_petition
    financial_information = user.financial_information || FinancialInformation.new

    if user.has_attorney
      attorney = user.attorney
      attorney_name = nil_check(attorney.name)
      attorney_firm_name = nil_check(attorney.firm_name)
      attorney_street_address = nil_check(attorney.street_address)
      attorney_city = nil_check(attorney.city)
      attorney_state = nil_check(attorney.state)
      attorney_zip = nil_check(attorney.zip)
      attorney_state_bar = if attorney.state_bar_number && attorney.state_bar_number != ''
                           "SB ##{attorney.state_bar_number}"
                           end

      lawyer_sentence = "#{attorney_name} #{attorney_firm_name} #{attorney_street_address} #{attorney_city} #{attorney_state} #{attorney_zip} #{attorney_state_bar}"
    else
      lawyer_sentence = 'PRO-SE'
    end

    pdf_fields = {
      'name' => user.name,
      'street_address' => user.street_address,
      'city' => user.city,
      'state' => user.state,
      'zip_code' => user.zip,
      'phone_number' => user.phone_number,
      'lawyer' => lawyer_sentence,
      'job_title' => financial_information.job_title,
      'employer_name' => financial_information.employer_name,
      'employer_address' => financial_information.employer_address,
      'low_income' => financial_information.monthly_income_under_limit ? 'On' : 'Off'
    }

    financial_information.benefits_programs.each do |benefit|
      pdf_fields[benefit] = 'On'
    end

    fill_petition('fw001.pdf', pdf_fields)
  end

  private

  def nil_check(info)
    if (info.nil?) || (info == '')
      return ''
    end
    return "#{info},"
  end

  attr_reader :user
end
