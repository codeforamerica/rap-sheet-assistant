require 'rails_helper'

describe 'uploading a rap sheet' do
  before do
    page_1_text = File.read('./spec/fixtures/skywalker_rap_sheet_page_1.txt')
    page_2_text = File.read('./spec/fixtures/skywalker_rap_sheet_page_2.txt')
    allow(TextScanner).to receive(:scan_text).and_return(page_1_text, page_2_text)
  end

  it 'allows the user to upload their rap sheet and shows convictions' do
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

    expect(page).to have_content '1 of 2 pages uploaded'
    within '#rap_sheet_page_2' do
      attach_file '+ add', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
      click_on 'Upload'
    end

    expect(page).to have_content 'All 2 pages added!'
    click_on 'Next'

    expect(page).to have_content 'We found 5 convictions on your record.'
    expect(page).to have_content '3 Felonies'
    expect(page).to have_content '1 Misdemeanor'
    expect(page).to have_content '1 Unknown'
    click_on 'Next'

    expect(page).to have_content 'Good news, you might be eligible to clear 5 convictions on your record'
    expect(page).to have_content 'We can help you apply to change 1 conviction'
    expect(page).to have_content 'POSSESS MARIJUANA'
    expect(page).to have_content 'Redesignation'
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

    expect(User.last.first_name).to eq('Testuser')
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
end
