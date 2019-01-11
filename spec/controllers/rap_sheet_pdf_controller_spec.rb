require 'rails_helper'

RSpec.describe RapSheetPdfController, type: :controller do
  describe '#create' do
    render_views

    context 'it is a RAP sheet pdf' do
      before do
        allow(TextScanner).to receive(:scan_text).
          with('spec/fixtures/skywalker_rap_sheet_page_2.jpg').
          and_return('page 2')
        allow(TextScanner).to receive(:scan_text).
          with('spec/fixtures/skywalker_rap_sheet_page_1.jpg').
          and_return('page 1 ')
        allow(ConvertPdfToImages).to receive(:convert).and_return(['spec/fixtures/skywalker_rap_sheet_page_1.jpg', 'spec/fixtures/skywalker_rap_sheet_page_2.jpg'])
      end

      it 'creates with supplied params' do
        post :create, params: {
          rap_sheet_pdf: {
            pdf_file: fixture_file_upload('skywalker_rap_sheet.pdf', 'document/pdf')
          }
        }

        rap_sheet = RapSheet.last
        expect(rap_sheet.number_of_pages).to eq(2)
        expect(rap_sheet.text).to eq 'page 1 page 2'

        expect(response).to redirect_to rap_sheet_path(rap_sheet)
      end
    end

    context 'it is an invalid upload' do
      before do
        allow(TextScanner).to receive(:scan_text).and_raise('some error')
      end

      it 'redirects to upload error page' do
        post :create, params: {
          rap_sheet_pdf: {
            pdf_file: fixture_file_upload('skywalker_rap_sheet.pdf', 'document/pdf')
          }
        }
        expect(response.body).to include('Upload error')
        expect(response.body).to include("Apologies")
      end
    end
  end
end
