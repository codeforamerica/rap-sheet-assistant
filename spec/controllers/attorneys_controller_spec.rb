require 'rails_helper'

RSpec.describe AttorneysController, type: :controller do
  describe '#create' do
    let(:user) { create(:user)}

    it 'creates an attorney' do
      post_params = {
        attorney: {
          name: 'Attorney Name',
          state_bar_number: '123456789',
          firm_name: 'Firm Name'
        }
      }

      post :create, params: post_params, session: { current_user_id: user.id }

      expect(Attorney.count).to eq 1
      attorney = Attorney.first
      expect(attorney.reload.name).to eq('Attorney Name')
      expect(attorney.reload.state_bar_number).to eq('123456789')
      expect(attorney.reload.firm_name).to eq('Firm Name')
    end
  end
end
