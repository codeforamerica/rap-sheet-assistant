require 'rails_helper'

describe 'uploading a rap sheet' do
  it 'shows welcome text' do
    visit root_path
    expect(page).to have_content 'Upload your RAP sheet here!'

    attach_file 'Upload', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'
  end
end
