require 'rails_helper'

RSpec.describe RapSheetsController, type: :controller do
  describe '#create' do
    it 'creates with supplied params' do
      post :create, params: {
        rap_sheet: {
          number_of_pages: 2
        }
      }

      expect(RapSheet.last.number_of_pages).to eq(2)
    end
  end
end
