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

    let(:text) do
      <<~TEXT
        info
        * * * *
        COURT:
        19740102 CASC SAN PRANCISCU rm
        
        CNT: 001 #123
        DISPO:DISMISSED
        * * * END OF MESSAGE * * *
      TEXT
    end

    let(:rap_sheet) do
      create(:rap_sheet,
        number_of_pages: 1,
        rap_sheet_pages: [RapSheetPage.new(text: text, page_number: 1)]
      )
    end

    it 'shows conviction counts' do
      get :show, params: { id: rap_sheet.id }

      expect(response.body).to include("we didn't find any convictions")
    end

    describe 'when the rap sheet cannot be parsed' do
      before do
        allow_any_instance_of(RapSheet).to receive(:parsed).and_raise(RapSheetParser::RapSheetParserException.new(nil, nil))
      end
      
      let(:rap_sheet) { create(:rap_sheet) }

      it 'redirects to the debug page' do
        capture_output do
          get :show, params: { id: rap_sheet.id }
        end

        expect(response).to redirect_to(debug_rap_sheet_path(rap_sheet.id))
      end
    end

    describe 'the "Next" link' do
      context 'when there are only prop64 convictions' do
        let(:text) { single_conviction_rap_sheet('11357 HS-POSSESS MARIJUANA') }

        it 'goes to the detail page' do
          get :show, params: { id: rap_sheet.id }

          expect(response.body).to include(details_rap_sheet_path(rap_sheet.id))
        end
      end

      context 'when there are convictions that are only eligible for pc1203 dismissal' do
        let(:text) { single_conviction_rap_sheet('496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY') }

        it 'goes to the case information form' do
          get :show, params: { id: rap_sheet.id }

          expect(response.body).to include(edit_user_case_information_path(rap_sheet.user))
        end
      end

      context 'when there are convictions but none are eligible for any kind of dismissal' do
        let(:text) do
          single_conviction_rap_sheet('496 PC-RECEIVE/ETC KNOWN STOLEN PROPERTY', sentence: '002 YEARS PRISON')
        end

        it 'goes to the ineligible page' do
          get :show, params: { id: rap_sheet.id }

          expect(response.body).to include(ineligible_rap_sheet_path(rap_sheet))
        end
      end
    end
  end

  describe '#details' do
    let(:rap_sheet) do
      create(:rap_sheet,
        number_of_pages: 1,
        rap_sheet_pages: [RapSheetPage.new(text: text, page_number: 1)]
      )
    end

    context 'when there are eligible convictions' do
      let(:text) { File.read('./spec/fixtures/skywalker_pc1203_eligible.txt') }

      it 'renders a detail page' do
        get :details, params: { id: rap_sheet.id }

        expect(response).to be_success
      end
    end

    context 'when there are no eligible convictions' do
      let(:text) { File.read('./spec/fixtures/skywalker_ineligible.txt') }
      before do
        rap_sheet.user.update(outstanding_warrant: true)
      end

      it 'redirects to the ineligible page' do
        get :details, params: { id: rap_sheet.id }

        expect(response).to redirect_to(ineligible_rap_sheet_path(rap_sheet))
      end
    end
  end

  describe '#debug' do
    render_views

    describe 'when the rap sheet cannot be parsed' do
      let(:rap_sheet) do
        create(:rap_sheet,
          number_of_pages: 1,
          rap_sheet_pages: [RapSheetPage.new(text: "fancy fjord\n", page_number: 1)]
        )
      end

      it 'shows a stack trace and the page content' do
        capture_output do
          get :debug, params: { id: rap_sheet.id }
        end

        expect(response.body).to include('fancy fjord')
      end
    end
  end

  describe '#add_page' do
    it 'increments the page count' do
      rap_sheet = create(:rap_sheet, number_of_pages: 2)
      expect do
        put :add_page, params: { id: rap_sheet.id }
      end.to change { rap_sheet.reload.number_of_pages }.from(2).to(3)
    end
  end

  describe '#remove_page' do
    context 'when there is only one page' do
      it 'does nothing' do
        rap_sheet = create(:rap_sheet, number_of_pages: 1)
        expect do
          put :remove_page, params: { id: rap_sheet.id }
        end.not_to change { rap_sheet.reload.number_of_pages }
      end
    end

    context 'when a last page has not been uploaded' do
      it 'decrements the page count' do
        rap_sheet = create(:rap_sheet, number_of_pages: 2)
        expect do
          put :remove_page, params: { id: rap_sheet.id }
        end.to change { rap_sheet.reload.number_of_pages }.from(2).to(1)
      end
    end

    context 'when there is an image uploaded for the last page' do
      it 'deletes the last page and decrements the page count' do
        rap_sheet = create(:rap_sheet,
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

  def single_conviction_rap_sheet(conviction_description, sentence: '012 MONTHS PROBATION, 045 DAYS JAIL')
    <<~EOT
      info
      * * * *
      COURT:                NAM:01
      19840918  CASC LOS ANGELES
      
      CNT:01     #1234567
        #{conviction_description}
      *DISPO:CONVICTED
         CONV STATUS:MISDEMEANOR
         SEN: #{sentence}      

      *    *    *    END OF MESSAGE    *    *    *
    EOT
  end
end
