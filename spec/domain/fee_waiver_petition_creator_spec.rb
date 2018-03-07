require 'rails_helper'

RSpec.describe FeeWaiverPetitionCreator do
  let(:financial_information) do
    FactoryBot.build(
      :financial_information,
      employed: false,
    )
  end

  let(:user) do
    FactoryBot.build(
      :user,
      first_name: 'Test',
      last_name: 'User',
      street_address: '123 Fake St',
      city: 'San Francisco',
      state: 'CA',
      zip_code: '12345',
      phone_number: '000-111-2222',
      financial_information: financial_information
    )
  end

  subject { get_fields_from_pdf(FeeWaiverPetitionCreator.new(user).create_petition) }

  it 'creates a filled-out form with the users contact info' do
    expected_values = {
      'name' => 'Test User',
      'street_address' => '123 Fake St',
      'city' => 'San Francisco',
      'state' => 'CA',
      'zip_code' => '12345',
      'phone_number' => '000-111-2222',
      'lawyer' => 'PRO-SE',
    }
    expect(subject).to include(expected_values)
  end

  context 'user is employed' do
    let(:financial_information) do
      FactoryBot.build(
        :financial_information,
        employed: true,
        job_title: 'Astronaut',
        employer_name: 'NASA',
        employer_address: '1 Space Age',
      )
    end

    it 'populates employment information' do
      expected_values = {
        'job_title' => 'Astronaut',
        'employer_name' => 'NASA',
        'employer_address' => '1 Space Age',
      }
      expect(subject).to include(expected_values)
    end
  end
end
