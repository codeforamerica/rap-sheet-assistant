require 'rails_helper'

RSpec.describe Users::RepresentationsController, type: :controller do
  describe '#yes' do
    let(:user) { create :user }

    let(:post_params) {
      {
        user_id: user.id
      }
    }
    context '#yes the user has representation' do
      it 'sets pro_se to false' do
        post :yes, params: post_params

        expect(user.reload.pro_se).to eq(false)
      end
    end

    context '#no the user does not have representation' do
      it 'sets pro_se to true' do
        post :no, params: post_params

        expect(user.reload.pro_se).to eq(true)
      end
    end
  end
end
