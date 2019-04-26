require 'rails_helper'

describe Users::ContactInformationsController, type: :controller do
  describe '#update' do
    let(:user) { create :user }

    before(:each) do
      create(:rap_sheet, user: user)
    end

    context 'the user is submitting info for the first time' do
      it 'saves the contact information on the user' do
        post :update, params: {
          user_id: user.id,
          contact_information_form: {
            name: 'Lucy Looloo',
            phone_number: '123-456-7890',
            street_address: '1 Elephant Lane',
            city: 'Circustown',
            state: 'CA',
            zip: '94121',
            'date_of_birth(1i)' => '1990',
            'date_of_birth(2i)' => '2',
            'date_of_birth(3i)' => '12',
            prefer_email: true,
            prefer_text: false
          }
        }

        expect(user.reload.name).to eq 'Lucy Looloo'
        expect(user.reload.phone_number).to eq '123-456-7890'
        expect(user.reload.street_address).to eq '1 Elephant Lane'
        expect(user.reload.city).to eq 'Circustown'
        expect(user.reload.state).to eq 'CA'
        expect(user.reload.zip).to eq '94121'
        expect(user.reload.date_of_birth).to eq Date.new(1990, 2, 12)
        expect(user.reload.prefer_email).to eq true
        expect(user.reload.prefer_text).to eq false
      end
    end

    context 'the user pressed back and is submitting info again' do
      let(:user) { create(:user,
                          name: 'Lucy Looloo',
                          phone_number: '123-456-7890',
                          street_address: '1 Elephant Lane',
                          city: 'Circustown',
                          state: 'CA',
                          zip: '94121',
                          date_of_birth: Date.new(1990, 2, 12),
                          prefer_email: true,
                          prefer_text: false) }

      it 'updates contact information' do
        expect(user.reload.name).to eq 'Lucy Looloo'

        post :update, params: {
          user_id: user.id,
          contact_information_form: {
            name: 'Lucy Lala',
            phone_number: '123-456-7890',
            street_address: '15 Seal Street',
            city: 'Circustown',
            state: 'CA',
            zip: '94121',
            'date_of_birth(1i)' => '1990',
            'date_of_birth(2i)' => '2',
            'date_of_birth(3i)' => '12',
            prefer_email: false,
            prefer_text: true
          }
        }

        expect(user.reload.name).to eq 'Lucy Lala'
        expect(user.reload.street_address).to eq '15 Seal Street'
        expect(user.reload.prefer_email).to eq false
        expect(user.reload.prefer_text).to eq true
      end
    end
  end
end
