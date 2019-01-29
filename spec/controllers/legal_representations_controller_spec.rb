require 'rails_helper'

RSpec.describe Users::LegalRepresentationsController, type: :controller do
  describe '#yes' do
    let(:user) { create :user }

    let(:post_params) {
      {
        user_id: user.id
      }
    }
    context '#yes the user has representation' do
      it 'sets has_attorney to false' do
        post :yes, params: post_params

        expect(user.reload.has_attorney).to eq(true)
      end
    end

    context '#no the user does not have representation' do
      it 'sets has_attorney to true' do
        post :no, params: post_params

        expect(user.reload.has_attorney).to eq(false)
      end
    end
  end
end
