require 'rails_helper'

describe 'uploading a rap sheet' do
  after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test"])
  end

  before do
    tesseract = double(:tesseract, to_s: '02 SKYWALKER,LUKE')
    allow(RTesseract).to receive(:new).and_return(tesseract)
  end

  it 'shows welcome text' do
    visit root_path
    expect(page).to have_content 'Upload your RAP sheet here!'

    attach_file 'Take photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'

    click_on 'Upload'

    expect(page).to have_content '02 SKYWALKER,LUKE'
  end
end
