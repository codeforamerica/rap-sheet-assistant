require 'rails_helper'

RSpec.describe AttorneysController, type: :controller do
  describe '#create' do
      it 'creates an attorney' do
        attorney = create( :attorney,
                           name: 'Attorney Name',
                           state_bar_number: '123456789',
                           firm_name: 'Firm Name'
        )

        post :create

        expect(attorney.reload.name).to eq('Attorney Name')
        expect(attorney.reload.state_bar_number).to eq('123456789')
        expect(attorney.reload.firm_name).to eq('Firm Name')
      end
  end
end
