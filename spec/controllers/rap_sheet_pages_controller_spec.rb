require 'rails_helper'

describe RapSheetPagesController do
  before do
    allow(TextScanner).to receive(:scan_text).and_return('page 1')
  end

  describe '#create' do
    context 'the rap sheet exists' do
      it 'adds rap sheet page to rap sheet' do
        rap_sheet = RapSheet.create!

        post :create, params: {
          rap_sheet_page: {
            rap_sheet_id: rap_sheet.id,
            rap_sheet_page_image: fixture_file_upload('skywalker_rap_sheet_page_1.jpg', 'image/jpg')
          }
        }

        expect(RapSheet.count).to eq 1
        expect(RapSheetPage.count).to eq 1
        expect(RapSheetPage.first.text).to eq 'page 1'

        expect(response).to redirect_to(edit_rap_sheet_path(rap_sheet.id))
      end
    end

    context 'the rap sheet does not exist' do
      it 'creates new rap sheet with rap sheet page' do
        post :create, params: {
          rap_sheet_page: {
            rap_sheet_id: "",
            rap_sheet_page_image: fixture_file_upload('skywalker_rap_sheet_page_1.jpg', 'image/jpg')
          }
        }

        expect(RapSheet.count).to eq 1
        expect(RapSheetPage.count).to eq 1
        expect(RapSheetPage.first.text).to eq 'page 1'

        expect(response).to redirect_to(edit_rap_sheet_path(RapSheet.first.id))
      end
    end
  end
end
