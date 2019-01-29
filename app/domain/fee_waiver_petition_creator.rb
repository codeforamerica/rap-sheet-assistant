class FeeWaiverPetitionCreator
  include PetitionCreator

  def initialize(user)
    @user = user
  end

  def create_petition
    financial_information = user.financial_information || FinancialInformation.new

    pdf_fields = {
      'name' => user.name,
      'street_address' => user.street_address,
      'city' => user.city,
      'state' => user.state,
      'zip_code' => user.zip,
      'phone_number' => user.phone_number,
      'lawyer' => 'PRO-SE',
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

  attr_reader :user
end
