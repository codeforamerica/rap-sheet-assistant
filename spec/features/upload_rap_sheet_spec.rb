require 'rails_helper'

describe 'uploading a rap sheet' do
  before do
    page_1_text = 'page 1'
    page_2_text = 'page 2'
    allow(TextScanner).to receive(:scan_text).and_return(page_1_text, page_2_text)
  end

  it 'shows welcome text' do
    visit root_path

    expect(page).to have_content 'Upload your RAP sheet here!'
    attach_file 'Take photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
    click_on 'Upload'

    expect(page).to have_content 'Upload any additional pages'
    attach_file 'Take photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
    click_on 'Upload'

    expect(page).to have_content 'Upload any additional pages'
    click_on 'Done'

    expect(page).to have_content 'page 1'
    expect(page).to have_content 'page 2'
  end
end
