require 'rails_helper'

describe 'uploading a rap sheet' do
  before do
    tesseract_page_1 = double(:tesseract, to_s: 'page 1')
    tesseract_page_2 = double(:tesseract, to_s: 'page 2')
    allow(RTesseract).to receive(:new).and_return(tesseract_page_1, tesseract_page_2)
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
