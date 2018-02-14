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

  describe '#show' do
    render_views

    it 'shows conviction counts' do
      text = <<~TEXT
        info
        * * * *
        COURT:
        19740102 CASC SAN PRANCISCU rm
        
        CNT: 001 #123
        DISPO:DISMISSED
        * * * END OF MESSAGE * * *
      TEXT

      rap_sheet = RapSheet.create!(
        number_of_pages: 1,
        rap_sheet_pages: [RapSheetPage.new(text: text, page_number: 1)]
      )

      get :show, params: { id: rap_sheet.id }

      expect(response.body).to include("we didn't find any convictions")
    end
  end
end
