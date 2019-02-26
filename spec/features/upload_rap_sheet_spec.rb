require 'rails_helper'

describe 'uploading a rap sheet', js: true, type: :feature do
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

  context 'when it is not a valid RAP sheet PDF and throws an exception' do
    before do
      allow(TextScanner).to receive(:scan_text).and_raise('error')
    end

    it 'redirects to the error page' do
      visit root_path
      expect(page).to have_content 'Upload a California RAP sheet'
      upload_pdf

      expect(page).to have_content 'Upload error'
      expect(page).to have_content "Apologies, we weren't able to read the file you uploaded"
    end
  end

  context 'when it is a valid RAP sheet PDF' do
    before do
      allow(TextScanner).to receive(:scan_text).and_return(*scanned_pages)
    end

    context 'when a user has multiple remedy types of eligible convictions' do
      it 'allows the user to upload their rap sheet and shows convictions' do
        visit root_path
        expect(page).to have_content 'Upload a California RAP sheet'
        upload_pdf

        expect(page).to have_content 'We found 4 convictions that may be eligible for record clearance.'
        expect(page).to have_content 'Prop 64 (1)'
        expect(page).to have_content '05/01/1986'
        expect(page).to have_content 'M'
        expect(page).to have_content 'HS 11357'
        expect(page).to have_content 'Possess Marijuana'
        expect(page).to have_content '#19514114'

        expect(page).to have_content '1203.4 discretionary (3)'
        expect(page).to have_content '11/15/2004'
        expect(page).to have_content 'F'
        expect(page).to have_content 'PC 451(a)'
        expect(page).to have_content 'Arson Causing Great Bodily Injury'
        expect(page).to have_content '#44050'

        expect(page).to have_content 'Prop 47 (1)'
        expect(page).to have_content '09/06/2011'
        expect(page).to have_content 'F'
        expect(page).to have_content 'PC 496(a)'
        expect(page).to have_content 'Receive/Etc Known Stolen Property'
        expect(page).to have_content '#99999988887777'
        click_on 'View full transcript'

        expect(page).to have_content 'Transcript'

        expect(page).to have_content 'Prop 64 (1)'
        expect(page).to have_content '05/01/1986'
        expect(page).to have_content 'M'
        expect(page).to have_content 'HS 11357'
        expect(page).to have_content 'Possess Marijuana'
        expect(page).to have_content '#19514114'

        expect(page).to have_content '1203.4 discretionary (3)'
        expect(page).to have_content '11/15/2004'
        expect(page).to have_content 'F'
        expect(page).to have_content 'PC 451(a)'
        expect(page).to have_content 'Arson Causing Great Bodily Injury'
        expect(page).to have_content '#44050'

        expect(page).to have_content 'Prop 47 (1)'
        expect(page).to have_content '09/06/2011'
        expect(page).to have_content 'F'
        expect(page).to have_content 'PC 496(a)'
        expect(page).to have_content 'Receive/Etc Known Stolen Property'
        expect(page).to have_content '#99999988887777'
        click_on 'Back to eligibility summary'

        click_on 'Next'

        click_on 'Yes, has a lawyer'

        fill_in_attorney_form

        click_on 'Next'

        expect(page).to have_field('Name', with: 'LUKE JAY SKYWALKER')
        expect(page).to have_select('contact_information_form[date_of_birth(2i)]', selected: 'January')
        expect(page).to have_select('contact_information_form[date_of_birth(3i)]', selected: '19')
        expect(page).to have_select('contact_information_form[date_of_birth(1i)]', selected: '1957')

        fill_in_contact_form(name: 'Test User')
        click_on 'Next'

        click_on 'Download paperwork'
        fields_dict = get_fields_from_downloaded_pdf('Test User')
        expected_values = {
          'Field10' => 'Test User',
          'Field1' => 'Ms. Attorney    State Bar No: 678999212',
          # Prop 64 form for marijuana case
          'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '19514114',
          # 1203 dismissal form for marijuana case
          'Field13' => '19514114',
          'Field43' => 'Yes',
          # 1203 dismissal form for arson case
          '2.Field13' => '44050',
          # Prop47 case
          'case_number' => '99999988887777',
          'code_sections' => 'PC 496(a)',
          'reduction_checkbox' => 'Yes'
        }
        expect(fields_dict).to include(expected_values)
      end

      it 'has a debugging page' do
        visit root_path
        expect(page).to have_content 'Upload a California RAP sheet'
        upload_pdf
        expect(page).to have_content 'We found'
        visit current_url + '/debug'

        expect(page).not_to have_content '20041115'

        click_on 'More information'

        expect(page).to have_content '20041115'
        expect(page).to have_content '44050'
        expect(page).to have_content 'CASC LOS ANGELES'
        expect(page).to have_content 'PC 451(a) --- ARSON CAUSING GREAT BODILY INJURY'
        expect(page).to have_content '2y jail, fine, restitution'
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

        click_on 'Yes, has a lawyer'

        fill_in_attorney_form

        click_on 'Next'

        fill_in_contact_form(name: 'Testuser Lastname')
        click_on 'Next'

        click_on 'Download paperwork'
        fields_dict = get_fields_from_downloaded_pdf('Testuser Lastname')
        expected_values = {
          'Field13' => '1234567',
          '2.Field13' => '3456789'
        }
        expect(fields_dict).to include(expected_values)
      end
    end

    context 'when the rap sheet has only a 1203-eligible dismissal' do
      let(:scanned_pages) do
        [
          File.read('spec/fixtures/skywalker_pc1203_eligible.txt')
        ]
      end

      it 'shows that it is dismissible' do
        visit root_path
        expect(page).to have_content 'Upload a California RAP sheet'
        upload_pdf

        expect(page).to have_content 'We found 1 conviction that may be eligible for record clearance.'
        click_on 'Next'

        click_on 'No, filing pro se'

        fill_in_contact_form(name: 'Testuser Smith')
        click_on 'Next'

        click_on 'Download paperwork'
        fields_dict = get_fields_from_downloaded_pdf('Testuser Smith')
        expected_values = {
          'Field13' => '5678901', # Case number
          'Field43' => 'Yes', # Box 2 (1203.4)
          'Field44' => 'Yes'  # Box 2a (successful completion)
        }
        expect(fields_dict).to include(expected_values)
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
        expect(page).to have_content 'No eligible convictions found'
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
      attach_rap_pdf_file
      expect(page).to have_content 'PDF added'
    end
  end


  def upload_pdf
    expect(page).to have_content 'Select a PDF file to upload'
    attach_rap_pdf_file
    click_on 'Upload'
    # expect(page).to have_content 'Searching for convictions'
  end

  def fill_in_case_information
    find('.form-group', text: 'Are you currently on parole?').choose('No')
    find('.form-group', text: 'Are you currently on probation?').choose('No')
    find('.form-group', text: 'Do you currently have any warrants?').choose('No')
    find('.form-group', text: 'Do you currently owe any court fines or fees?').choose('No')
  end

  def fill_in_contact_form(params = {})
    fill_in 'Name', with: params[:name] || 'Clearme'
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

  def fill_in_attorney_form(params = {})
    fill_in "Attorney's name", with: params[:name] || 'Ms. Attorney'
    fill_in 'State bar number', with: params[:state_bar_number] || '678999212'
    fill_in 'Firm name', with: params[:firm_name] || 'Issa Firm'
    fill_in 'Street address', with: params[:street_address] || '123 Main St'
    fill_in 'City', with: params[:city] || 'San Francisco'
    fill_in 'State', with: params[:state] || 'CA'
    fill_in 'Zip', with: params[:zip_code] || '94103'
    fill_in 'Phone number', with: params[:phone_number] || '555555555'
    fill_in 'Email address', with: params[:email_address] || 'testuser@example.com'
  end

  def get_fields_from_downloaded_pdf(name)
    today = Date.today
    tempfile = "/tmp/downloads/rap-sheet-assistant/cmr_petitions_#{name.tr(" ", "_")}_#{today.strftime("%Y-%m-%d")}.pdf".downcase
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
