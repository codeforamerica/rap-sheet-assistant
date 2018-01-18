require 'rails_helper'

describe 'uploading a rap sheet' do
  after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test"])
  end

  it 'shows welcome text' do
    visit root_path
    expect(page).to have_content 'Upload your RAP sheet here!'

    attach_file 'Take photo', 'spec/fixtures/skywalker_rap_sheet_page_1.jpg'

    click_on 'Upload'

    expect(page).to have_content 'Successfully uploaded!'
  end
end
