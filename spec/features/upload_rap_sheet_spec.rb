require 'rails_helper'

describe 'uploading a rap sheet' do
  it 'shows welcome text' do
    visit root_path
    expect(page).to have_content 'Upload your RAP sheet here!'
  end
end
