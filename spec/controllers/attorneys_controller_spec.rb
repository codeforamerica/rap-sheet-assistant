require 'rails_helper'

RSpec.describe AttorneysController, type: :controller do
  describe '#create' do
    let(:user) { create(:user)}

    it 'creates an attorney' do
      post_params = {
        user_id: user.id,
        attorney: {
          name: 'Attorney Name',
          state_bar_number: '123456789',
          firm_name: 'Firm Name',
          street_address: '1234 Main St',
          city: 'San Francisco',
          state: 'CA',
          zip: '12345',
          phone_number: '5555555555',
          email: 'myemail@example.com'
        }
      }

      post :create, params: post_params

      expect(Attorney.count).to eq 1
      attorney = Attorney.first
      expect(attorney.reload.name).to eq('Attorney Name')
      expect(attorney.reload.state_bar_number).to eq('123456789')
      expect(attorney.reload.firm_name).to eq('Firm Name')
      expect(attorney.reload.street_address).to eq('1234 Main St')
      expect(attorney.reload.city).to eq('San Francisco')
      expect(attorney.reload.state).to eq('CA')
      expect(attorney.reload.zip).to eq('12345')
      expect(attorney.reload.phone_number).to eq('5555555555')
      expect(attorney.reload.email).to eq('myemail@example.com')
    end
  end
end
