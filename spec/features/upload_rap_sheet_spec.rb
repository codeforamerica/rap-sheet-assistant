require 'rails_helper'

describe 'uploading a rap sheet' do
  let(:scanned_pages) do
    [
      File.read('./spec/fixtures/skywalker_rap_sheet_page_1.txt'),
      File.read('./spec/fixtures/skywalker_rap_sheet_page_2.txt')
    ]
  end

  before do
    allow(ConvertPdfToImages).
      to receive(:convert).
        and_return(
          ['./spec/fixtures/skywalker_rap_sheet_page_1.jpg',
           './spec/fixtures/skywalker_rap_sheet_page_2.jpg']
        )
  end

  before do
    allow(TextScanner).to receive(:scan_text).and_return(*scanned_pages)
  end

  context 'when a user has both prop64 and 1203 dismissal eligible convictions' do
    it 'allows the user to upload their rap sheet and shows convictions' do
      visit root_path
      expect(page).to have_content 'Upload a California RAP sheet'
      upload_pdf

      expect(page).to have_content 'We found 1 conviction that may be eligible for record clearance.'
      expect(page).to have_content 'Prop 64 (1)'
      expect(page).to have_content '05/01/1986'
      expect(page).to have_content 'M'
      expect(page).to have_content 'HS 11357'
      expect(page).to have_content 'Possess Marijuana'
      expect(page).to have_content '#19514114'
      click_on 'Next'

      fill_in_case_information
      click_on 'Next'

      expect(page).to have_content 'Good news, you might be eligible to clear 3 convictions on your record'
      expect(page).to have_content 'We can help you apply to reclassify 1 marijuana conviction'
      expect(page).to have_content 'POSSESS MARIJUANA'
      click_on 'Next'

      # COMMENTING OLD TEST, WHILE NEW STORIES ARE APPLIED
      # fill_in_case_information
      # click_on 'Next'
      #
      # expect(page).to have_content 'Good news, you might be eligible to clear 3 convictions on your record'
      # expect(page).to have_content 'We can help you apply to reclassify 1 marijuana conviction'
      # expect(page).to have_content 'POSSESS MARIJUANA'
      # click_on 'Debug'
      #
      # expect(page).to have_content '1990-12-14'
      # expect(page).to have_content 'XR09005'
      # expect(page).to have_content 'CASC LOS ANGELES'
      # expect(page).to have_content 'PC 192.3(a) --- VEH MANSL W/GROSS NEGLIGENCE'
      # expect(page).to have_content '3y probation, 30d jail, fine, restitution'
      # click_on 'Back'
      # click_on 'Next'
      #
      # fill_in_contact_form(first_name: 'Test', last_name: 'User')
      # click_on 'Next'
      #
      # find('.form-group', text: 'Are you currently employed?').choose 'No'
      #
      # click_on 'Next'
      #
      # check 'Food Stamps'
      #
      # click_on 'Next'
      #
      # click_on 'download'
      # fields_dict = get_fields_from_downloaded_pdf('Test', 'User')
      # expected_values = {
      #   'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'PRO-SE',
      #   'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => 'Test User',
      #   'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '19514114',
      #   'topmostSubform[0].Page1[0].Caption_sf[0].CaseNumber[0].CaseNumber_ft[0]' => '44050',
      #   'topmostSubform[0].Page2[0].OffenseWSentence_cb[1]' => '1',
      #   'topmostSubform[0].Page2[0].DismissSection_cb[3]' => '3'
      # }
      # expect(fields_dict).to include(expected_values)
    end
  end

  context 'when the rap sheet contains only prop64 conviction events' do
    let(:scanned_pages) do
      [
        File.read('./spec/fixtures/skywalker_prop64_two_cases_both_convicted.txt')
      ]
    end

    it 'generates multiple petitions for independent conviction events' do
      visit root_path
      expect(page).to have_content 'Upload a California RAP sheet'
      upload_pdf

      click_on 'Next'
      click_on 'Next'

      fill_in_contact_form(first_name: 'Testuser', last_name: 'Lastname')
      click_on 'Next'

      find('.form-group', text: 'Are you currently employed?').choose 'Yes'
      click_on 'Next'

      check 'Food Stamps'
      click_on 'Next'

      click_on 'download'
      fields_dict = get_fields_from_downloaded_pdf('Testuser', 'Lastname')
      expected_values = {
        'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '1234567',
        '1.topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '3456789'
      }
      expect(fields_dict).to include(expected_values)
    end
  end

  context 'when the rap sheet has only a 1203-eligible dismissal and the user is on public benefits' do
    let(:scanned_pages) do
      [
        File.read('spec/fixtures/skywalker_pc1203_eligible.txt')
      ]
    end

    it 'shows that it is dismissible' do
      visit root_path
      expect(page).to have_content 'Upload a California RAP sheet'
      upload_pdf

      expect(page).to have_content 'We found 0 convictions that may be eligible for record clearance.'
      click_on 'Next'

      fill_in_case_information
      click_on 'Next'

      expect(page).to have_content 'We can help you apply to dismiss 1 conviction'
      expect(page).to have_content 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      click_on 'Next'

      fill_in_contact_form(first_name: 'Testuser', last_name: 'Smith')
      click_on 'Next'

      expect(page).to have_content 'Financial Information'
      find('.form-group', text: 'Are you currently employed?').choose 'No'
      expect(page).not_to have_content('What is your job title?')
      expect(page).not_to have_content("What is your employer's name?")
      expect(page).not_to have_content("What is your employer's address?")
      find('.form-group', text: 'Are you currently employed?').choose 'Yes'
      fill_in 'What is your job title?', with: 'Mailman'
      fill_in "What is your employer's name?", with: 'USPS'
      fill_in "What is your employer's address?", with: '1 I love mail lane'

      click_on 'Next'

      check 'Food Stamps'
      check 'Medi-Cal'

      click_on 'Next'

      click_on 'download'
      fields_dict = get_fields_from_downloaded_pdf('Testuser', 'Smith')
      expected_values = {
        'topmostSubform[0].Page1[0].Caption_sf[0].CaseNumber[0].CaseNumber_ft[0]' => '5678901',
        'name' => 'Testuser Smith',
        'job_title' => 'Mailman',
        'employer_name' => 'USPS',
        'employer_address' => '1 I love mail lane',
        'food_stamps' => 'On',
        'medi_cal' => 'On',
        'topmostSubform[0].Page1[0].ProbationGranted_cb[0]' => '1',
        'topmostSubform[0].Page1[0].ProbationGrantedReason[0]' => '1'
      }
      expect(fields_dict).to include(expected_values)
    end
  end

  context 'when the rap sheet has a 1203-eligible dismissal and the user is not on public benefits' do
    let(:scanned_pages) do
      [
        File.read('spec/fixtures/skywalker_pc1203_eligible.txt')
      ]
    end

    it 'shows that it is dismissible' do
      visit root_path
      expect(page).to have_content 'Upload a California RAP sheet'
      upload_pdf

      expect(page).to have_content 'We found 0 convictions that may be eligible for record clearance.'
      click_on 'Next'

      fill_in_case_information
      click_on 'Next'

      expect(page).to have_content 'We can help you apply to dismiss 1 conviction'
      expect(page).to have_content 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      click_on 'Next'

      fill_in_contact_form(first_name: 'Testuser', last_name: 'Smith')
      click_on 'Next'

      expect(page).to have_content 'Financial Information'
      find('.form-group', text: 'Are you currently employed?').choose 'No'
      expect(page).not_to have_content('What is your job title?')
      expect(page).not_to have_content("What is your employer's name?")
      expect(page).not_to have_content("What is your employer's address?")
      find('.form-group', text: 'Are you currently employed?').choose 'Yes'
      fill_in 'What is your job title?', with: 'Mailman'
      fill_in "What is your employer's name?", with: 'USPS'
      fill_in "What is your employer's address?", with: '1 I love mail lane'

      click_on 'Next'

      click_on 'Next'

      fill_in 'How many people do you live with, including yourself?', with: 4
      find('.form-group', text: 'Is your monthly income less than $2,614.59?').choose('Yes')

      click_on 'Next'

      click_on 'download'
      fields_dict = get_fields_from_downloaded_pdf('Testuser', 'Smith')
      expected_values = {
        'topmostSubform[0].Page1[0].Caption_sf[0].CaseNumber[0].CaseNumber_ft[0]' => '5678901',
        'name' => 'Testuser Smith',
        'job_title' => 'Mailman',
        'employer_name' => 'USPS',
        'employer_address' => '1 I love mail lane',
        'low_income' => 'On'
      }
      expect(fields_dict).to include(expected_values)

      expect(User.last.financial_information.monthly_income_limit).to eq 2614.59
    end
  end

  context 'when the rap sheet has no eligible convictions' do
    let(:scanned_pages) do
      [
        File.read('./spec/fixtures/skywalker_ineligible.txt')
      ]
    end

    it 'shows an ineligible page' do
      visit root_path
      upload_pdf

      click_on 'Next'
      expect(page).to have_content 'none of your convictions are eligible'
    end
  end

  it 'allows the user to select a different file' do
    visit root_path
    expect(page).to have_content 'Upload a California RAP sheet'

    expect(page).to have_content 'Select a PDF file to upload'
    attach_rap_pdf_file
    expect(page).to have_content 'PDF added'
    find('.icon-close').click
    expect(page).not_to have_content 'PDF added'
  end

  def upload_pdf
    expect(page).to have_content 'Select a PDF file to upload'
    attach_rap_pdf_file
    click_on 'Upload'
  end

  def fill_in_case_information
    find('.form-group', text: 'Are you currently on parole?').choose('No')
    find('.form-group', text: 'Are you currently on probation?').choose('No')
    find('.form-group', text: 'Do you currently have any warrants?').choose('No')
    find('.form-group', text: 'Do you currently owe any court fines or fees?').choose('No')
  end

  def fill_in_contact_form(params = {})
    fill_in 'What is your first name?', with: params[:first_name] || 'Clearme'
    fill_in 'What is your last name?', with: params[:last_name] || 'Smith'
    fill_in 'Phone number', with: params[:phone_number] || '415 555 1212'
    fill_in 'Email address', with: params[:email_address] || 'testuser@example.com'
    fill_in 'Street address', with: params[:street_address] || '123 Main St'
    fill_in 'City', with: params[:city] || 'San Francisco'
    fill_in 'State', with: params[:state] || 'CA'
    fill_in 'Zip', with: params[:zip_code] || '94103'
    select params[:dob_month] || 'January', from: 'contact_information_form[date_of_birth(2i)]'
    select params[:dob_day] || '1', from: 'contact_information_form[date_of_birth(3i)]'
    select params[:dob_year] || '1980', from: 'contact_information_form[date_of_birth(1i)]'
  end

  def get_fields_from_downloaded_pdf(firstname, lastname)
    today = Date.today
    tempfile = "/tmp/downloads/cmr_petitions_#{firstname}_#{lastname}_#{today.year}-#{today.month}-#{today.day}.pdf".downcase
    wait_until do
      File.exist?(tempfile)
    end
    get_fields_from_pdf(File.new(tempfile))
  end

  def attach_rap_pdf_file
    attach_file 'Select file', File.absolute_path('spec/fixtures/skywalker_rap_sheet.pdf'), make_visible: true
  end

  def wait_until
    times = 0
    until yield || times > 10 do
      times += 1
      sleep 0.1
    end
  end
end
