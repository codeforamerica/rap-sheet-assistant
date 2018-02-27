class DocumentsController < ApplicationController
  def index
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user
  end

  def download
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user

    conviction_events = @rap_sheet.dismissible_conviction_events
    return redirect_to rap_sheet_documents_path(@rap_sheet) unless conviction_events.present?

    petitions = conviction_events.map do |conviction_event|
      Prop64PetitionCreator.new(@rap_sheet, conviction_event).create_petition
    end
    send_file concatenate_pdfs(petitions), filename: download_filename(conviction_events)
  end

  def concatenate_pdfs(pdfs)
    pdftk = PdfForms.new(Cliver.detect('pdftk'))
    Tempfile.new('concatenated-pdfs').tap do |tempfile|
      pdftk.cat(*pdfs, tempfile)
    end
  end

  def download_filename(conviction_events)
    full_name_for_filename = @user.full_name.gsub(/[^0-9A-Za-z]/, '_')
    case_numbers_for_filename = conviction_events.map do |conviction_event|
      conviction_event.case_number.gsub(',', '_').gsub(/[^0-9A-Za-z]/, '')
    end

    ['prop64_petition', full_name_for_filename].concat(case_numbers_for_filename).join('_') + '.pdf'
  end
end
