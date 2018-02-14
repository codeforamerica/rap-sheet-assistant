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

    expect(page).to have_content 'Add a photo for page 1 of 2'
    expect(page).to have_content 'You need 2 more photos'
    attach_file '+ add photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
    click_on 'Upload'

    expect(page).to have_content 'Add a photo for page 2 of 2'
    expect(page).to have_content 'You need 1 more photo'
    attach_file '+ add photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
    click_on 'Upload'

    expect(page).to have_content 'You have successfully added all 2 pages of your RAP sheet!'
    click_on 'Next'

    expect(page).to have_content 'We found 5 convictions on your record.'
    expect(page).to have_content '3 Felonies'
    expect(page).to have_content '1 Misdemeanor'
    expect(page).to have_content '1 Unknown'
    click_on 'Next'

    expect(page).to have_content '1990-12-14'
    expect(page).to have_content 'XR09005'
    expect(page).to have_content 'CASC LOS ANGELES'
    expect(page).to have_content 'PC 192.3(A) --- VEH MANSL W/GROSS NEGLIGENCE'
  end
end
