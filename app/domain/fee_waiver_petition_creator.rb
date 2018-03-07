class FeeWaiverPetitionCreator
  def initialize(user)
    @user = user
  end

  def create_petition
    financial_information = user.financial_information

    pdf_fields = {
      'name' => user.full_name,
      'street_address' => user.street_address,
      'city' => user.city,
      'state' => user.state,
      'zip_code' => user.zip_code,
      'phone_number' => user.phone_number,
      'lawyer' => 'PRO-SE',
      'job_title' => financial_information.job_title,
      'employer_name' => financial_information.employer_name,
      'employer_address' => financial_information.employer_address,
    }

    tempfile = Tempfile.new('filled-pdf')

    pdftk = PdfForms.new(Cliver.detect('pdftk'))

    pdftk.fill_form Rails.root.join('app', 'assets', 'petitions', 'fw001.pdf'), tempfile.path, fields_for_pdftk(pdf_fields)

    tempfile
  end

  private

  attr_reader :user

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
end
