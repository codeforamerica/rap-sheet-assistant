require 'rails_helper'

describe Users::FinancialInformationsController, type: :controller do
  describe '#create' do
    let(:user) { FactoryBot.create :user }

    context 'the user is submitting info for the first time' do
      it 'creates financial information' do
        post :create, params: {
          user_id: user.id,
          financial_information: {
            employed: true,
            job_title: 'Clown',
            employer_name: 'The circus',
            employer_address: '1 Elephant Lane'
          }
        }

        expect(user.reload.financial_information.job_title).to eq 'Clown'
      end
      end

    context 'the user pressed back and is submitting info again' do
      before do
        FinancialInformation.create!(user: user, employed: false)
      end

      it 'updates financial information' do
        post :create, params: {
          user_id: user.id,
          financial_information: {
            employed: true,
            job_title: 'Clown',
            employer_name: 'The circus',
            employer_address: '1 Elephant Lane'
          }
        }

        expect(user.reload.financial_information.job_title).to eq 'Clown'
        expect(FinancialInformation.count).to eq 1
      end
    end
  end
end
