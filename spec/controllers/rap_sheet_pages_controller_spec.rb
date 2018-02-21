require 'rails_helper'

describe RapSheetPagesController do
  before do
    allow(TextScanner).to receive(:scan_text).and_return('page 1')
  end

  describe '#create' do
    it 'adds rap sheet page to rap sheet' do
      rap_sheet = RapSheet.create!(number_of_pages: 3)

      post :create, params: {
        rap_sheet_page: {
          rap_sheet_id: rap_sheet.id,
          rap_sheet_page_image: fixture_file_upload('skywalker_rap_sheet_page_1.jpg', 'image/jpg'),
          page_number: 1
        }
      }

      expect(RapSheet.count).to eq 1
      expect(RapSheetPage.count).to eq 1
      expect(RapSheetPage.first.text).to eq 'page 1'

      expect(response).to redirect_to(edit_rap_sheet_path(rap_sheet.id))
    end
  end

  describe '#destroy' do
    let(:image) { File.new(Rails.root.join('spec', 'fixtures', 'skywalker_rap_sheet_page_1.jpg')) }

    it 'removes a page' do
      rap_sheet = RapSheet.create!(number_of_pages: 1)
      rap_sheet_page = rap_sheet.rap_sheet_pages.create!(page_number: 1, rap_sheet_page_image: image)

      expect do
        delete :destroy, params: { id: rap_sheet_page.id }
      end.to change(RapSheetPage, :count).by(-1)

      expect(rap_sheet.reload.rap_sheet_pages.length).to eq(0)

      expect(response).to redirect_to(edit_rap_sheet_path(rap_sheet.id))
    end
  end
end
