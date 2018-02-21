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

    it 'creates the associated user' do
      expect do
        post :create, params: {
          rap_sheet: {
            number_of_pages: 2
          }
        }
      end.to change(User, :count).by(1)

      expect(RapSheet.last.user).to be
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

      rap_sheet = FactoryBot.create(
        :rap_sheet,
        number_of_pages: 1,
        rap_sheet_pages: [RapSheetPage.new(text: text, page_number: 1)]
      )

      get :show, params: { id: rap_sheet.id }

      expect(response.body).to include("we didn't find any convictions")
    end
  end

  describe '#add_page' do
    it 'increments the page count' do
      rap_sheet = FactoryBot.create(:rap_sheet, number_of_pages: 2)
      expect do
        put :add_page, params: { id: rap_sheet.id }
      end.to change { rap_sheet.reload.number_of_pages }.from(2).to(3)
    end
  end

  describe '#remove_page' do
    context 'when there is only one page' do
      it 'does nothing' do
        rap_sheet = FactoryBot.create(:rap_sheet, number_of_pages: 1)
        expect do
          put :remove_page, params: { id: rap_sheet.id }
        end.not_to change { rap_sheet.reload.number_of_pages }
      end
    end

    context 'when a last page has not been uploaded' do
      it 'decrements the page count' do
        rap_sheet = FactoryBot.create(:rap_sheet, number_of_pages: 2)
        expect do
          put :remove_page, params: { id: rap_sheet.id }
        end.to change { rap_sheet.reload.number_of_pages }.from(2).to(1)
      end
    end

    context 'when there is an image uploaded for the last page' do
      it 'deletes the last page and decrements the page count' do
        rap_sheet = FactoryBot.create(
          :rap_sheet,
          number_of_pages: 2,
          rap_sheet_pages: [
            RapSheetPage.new(text: 'sample_text', page_number: 1),
            RapSheetPage.new(text: 'sample_text', page_number: 2)
          ]
        )
        expect do
          put :remove_page, params: { id: rap_sheet.id }
        end.to change { rap_sheet.reload.number_of_pages }.from(2).to(1)
        expect(rap_sheet.rap_sheet_pages.length).to eq(1)
        expect(rap_sheet.rap_sheet_pages.first.page_number).to eq(1)
      end
    end
  end
end
