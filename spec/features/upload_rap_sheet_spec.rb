require 'rails_helper'

describe 'uploading a rap sheet' do
  let(:scanned_pages) do
    [
      File.read('./spec/fixtures/skywalker_rap_sheet_page_1.txt'),
      File.read('./spec/fixtures/skywalker_rap_sheet_page_2.txt')
    ]
  end

  before do
    allow(TextScanner).to receive(:scan_text).and_return(*scanned_pages)
  end

  it 'allows the user to upload their rap sheet and shows convictions' do
    visit root_path
    expect(page).to have_content 'Upload your California RAP sheet'
    click_on 'Start'

    upload_pages(scanned_pages)

    expect(page).to have_content 'We found 5 convictions on your record.'
    expect(page).to have_content '3 Felonies'
    expect(page).to have_content '1 Misdemeanor'
    expect(page).to have_content '1 Unknown'
    click_on 'Next'

    fill_in_case_information
    click_on 'Next'

    expect(page).to have_content 'Good news, you might be eligible to clear 2 convictions on your record'
    expect(page).to have_content 'We can help you apply to reclassify 1 marijuana conviction'
    expect(page).to have_content 'POSSESS MARIJUANA'
    click_on 'Debug'

    expect(page).to have_content '1990-12-14'
    expect(page).to have_content 'XR09005'
    expect(page).to have_content 'CASC LOS ANGELES'
    expect(page).to have_content 'PC 192.3(A) --- VEH MANSL W/GROSS NEGLIGENCE'
    expect(page).to have_content '3y probation, 30d jail, fine, restitution'
    click_on 'Back'
    click_on 'Next'

    fill_in_contact_form(first_name: 'Testuser')
    click_on 'Next'

    click_on 'download'
    fields_dict = get_fields_from_downloaded_pdf
    expected_values = {
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyFor_ft[0]' => 'PRO-SE',
      'topmostSubform[0].Page1[0].Caption_sf[0].AttyInfo[0].AttyName_ft[0]' => 'Testuser Smith',
      'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '19514114'
    }
    expect(fields_dict).to match(a_hash_including(expected_values))
  end

  context 'when the rap sheet contains multiple prop64 conviction events' do
    let(:scanned_pages) do
      [
        File.read('./spec/fixtures/skywalker_prop64_two_cases_both_convicted.txt')
      ]
    end

    it 'generates multiple petitions for independent conviction events' do
      visit root_path
      expect(page).to have_content 'Upload your California RAP sheet'
      click_on 'Start'

      upload_pages(scanned_pages)

      click_on 'Next'
      click_on 'Next'

      fill_in_contact_form(first_name: 'Testuser')
      click_on 'Next'

      click_on 'download'
      fields_dict = get_fields_from_downloaded_pdf
      expected_values = {
        'topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '1234567',
        '1.topmostSubform[0].Page1[0].Caption_sf[0].Stamp[0].CaseNumber_ft[0]' => '3456789'
      }
      expect(fields_dict).to match(a_hash_including(expected_values))
    end
  end

  context 'when the rap sheet has a 1203-eligible dismissal' do
    let(:scanned_pages) do
      [
        File.read('spec/fixtures/skywalker_pc1203_eligible.txt')
      ]
    end

    it 'shows that it is dismissible' do
      visit root_path
      expect(page).to have_content 'Upload your California RAP sheet'
      click_on 'Start'

      upload_pages(scanned_pages)

      expect(page).to have_content 'We found 1 conviction on your record'
      click_on 'Next'

      fill_in_case_information
      click_on 'Next'

      expect(page).to have_content 'We can help you apply to dismiss 1 conviction'
      expect(page).to have_content 'RECEIVE/ETC KNOWN STOLEN PROPERTY'
      click_on 'Next'

      fill_in_contact_form(first_name: 'Testuser')
      click_on 'Next'

      click_on 'download'
      fields_dict = get_fields_from_downloaded_pdf
      expected_values = {
        'topmostSubform[0].Page1[0].Caption_sf[0].CaseNumber[0].CaseNumber_ft[0]' => '5678901'
      }
      expect(fields_dict).to match(a_hash_including(expected_values))
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
      expect(page).to have_content 'Upload your California RAP sheet'
      click_on 'Start'

      upload_pages(scanned_pages)

      click_on 'Next'
      expect(page).to have_content 'none of your convictions are eligible'
    end
  end

  it 'allows the user to delete and re-upload pages' do
    visit root_path
    expect(page).to have_content 'Upload your California RAP sheet'
    click_on 'Start'

    expect(page).to have_content 'How many pages does your RAP sheet have?'
    fill_in 'How many pages does your RAP sheet have?', with: '2'
    click_on 'Next'

    expect(page).to have_content 'Upload all 2 pages of your RAP sheet'
    expect(page).to have_content '0 of 2 pages uploaded'
    within '#rap_sheet_page_1' do
      attach_file '+ add', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
      click_on 'Upload'
    end

    expect(RapSheet.last.rap_sheet_pages.length).to eq(1)

    within '#rap_sheet_page_1' do
      click_on '×'
    end

    expect(RapSheet.last.rap_sheet_pages.length).to eq(0)
  end

  it 'allows the user to add and remove pages' do
    visit root_path
    expect(page).to have_content 'Upload your California RAP sheet'
    click_on 'Start'

    expect(page).to have_content 'How many pages does your RAP sheet have?'
    fill_in 'How many pages does your RAP sheet have?', with: '2'
    click_on 'Next'

    click_on '+ add a page'
    expect(page).to have_css('.rap-sheet-page-row', count: 3)

    click_on '- remove a page'
    expect(page).to have_css('.rap-sheet-page-row', count: 2)
  end

  def upload_pages(rap_sheet_pages)
    expect(page).to have_content 'How many pages does your RAP sheet have?'
    fill_in 'How many pages does your RAP sheet have?', with: rap_sheet_pages.length
    click_on 'Next'

    pluralized_rap_sheet_pages = "#{rap_sheet_pages.length} #{'page'.pluralize(rap_sheet_pages.length)}"
    expect(page).to have_content "Upload all #{pluralized_rap_sheet_pages} of your RAP sheet"

    rap_sheet_pages.each_with_index do |_rap_sheet_page, index|
      expect(page).to have_content "#{index} of #{pluralized_rap_sheet_pages} uploaded"
      within "#rap_sheet_page_#{index + 1}" do
        attach_file '+ add', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
        click_on 'Upload'
      end
    end

    expect(page).to have_content "All #{pluralized_rap_sheet_pages} added!"
    click_on 'Next'
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
    select params[:dob_month] || 'January', from:  'contact_information_form[date_of_birth(2i)]'
    select params[:dob_day] || '1', from: 'contact_information_form[date_of_birth(3i)]'
    select params[:dob_year] || '1980', from: 'contact_information_form[date_of_birth(1i)]'
  end

  def get_fields_from_downloaded_pdf
    tempfile = Tempfile.new('downloaded_pdf', :encoding => 'ascii-8bit')
    tempfile.write(page.body)
    tempfile.close

    get_fields_from_pdf(tempfile)
  end
end
