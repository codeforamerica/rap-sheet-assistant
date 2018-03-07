module PetitionCreator
  private

  def fill_petition(petition_name, fields)
    tempfile = Tempfile.new('filled-pdf')

    pdftk = PdfForms.new(Cliver.detect('pdftk'))

    pdftk.fill_form Rails.root.join('app', 'assets', 'petitions', petition_name), tempfile.path, fields_for_pdftk(fields)

    tempfile
  end

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
