require 'rails_helper'

RSpec.describe Users::BenefitsController, type: :controller do
  describe '#create' do
    let(:user) {
      FactoryBot.create(
        :user,
        financial_information: FactoryBot.build(:financial_information, employed: false),
        rap_sheet: FactoryBot.build(:rap_sheet)
      )
    }
    context 'user is on benefits programs' do
      let(:post_params) {
        {
          user_id: user.id,
          financial_information: {
            benefits_programs: ['', 'medi_cal']
          }
        }
      }
      it 'populates financial information with benefits info' do
        post :create, params: post_params

        expect(user.financial_information.reload.benefits_programs).to eq(['medi_cal'])
      end

      it 'redirects to rap sheets documents path' do
        post :create, params: post_params

        expect(response).to redirect_to rap_sheet_documents_path(user.rap_sheet)
      end
    end

    context 'user is not on benefits programs' do
      let(:post_params) {
        {
          user_id: user.id,
          financial_information: {
            benefits_programs: ['']
          }
        }
      }

      it 'redirects to income informations path' do
        post :create, params: post_params

        expect(response).to redirect_to new_user_income_information_path(user)
      end
    end
  end
end
