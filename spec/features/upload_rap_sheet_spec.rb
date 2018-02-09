require 'rails_helper'

describe 'uploading a rap sheet' do
  before do
    page_1_text = File.read('./spec/fixtures/skywalker_rap_sheet_page_1.txt')
    page_2_text = File.read('./spec/fixtures/skywalker_rap_sheet_page_2.txt')
    allow(TextScanner).to receive(:scan_text).and_return(page_1_text, page_2_text)
  end

  it 'allows the user to upload their rap sheet and shows convictions' do
    visit root_path

    expect(page).to have_content 'Upload your RAP sheet here!'
    attach_file 'Take photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
    click_on 'Upload'

    expect(page).to have_content 'Upload any additional pages'
    attach_file 'Take photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
    click_on 'Upload'

    expect(page).to have_content 'Upload any additional pages'
    click_on 'Done'

    expect(page).to have_content '1990-12-14'
    expect(page).to have_content 'XR09005'
    expect(page).to have_content 'CASC LOS ANGELES'
    expect(page).to have_content 'PC 192.3(A) --- VEH MANSL W/GROSS NEGLIGENCE'
  end
end
