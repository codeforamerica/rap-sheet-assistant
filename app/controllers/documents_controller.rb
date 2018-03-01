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

    send_file concatenate_pdfs(petitions_for_conviction_events(conviction_events)), filename: download_filename(conviction_events)
  end

  def petitions_for_conviction_events(conviction_events)
    result = []

    conviction_events.each do |conviction_event|
      prop64_counts, other_counts = conviction_event.counts.partition { |count| Prop64Classifier.new(@rap_sheet.user, count).eligible? }

      if prop64_counts.present?
        result << Prop64PetitionCreator.new(@rap_sheet, prop64_counts.first.event).create_petition
      end

      if other_counts.present?
        result << PC1203PetitionCreator.new(@rap_sheet, other_counts).create_petition
      end
    end

    result
  end

  def concatenate_pdfs(pdfs)
    pdftk = PdfForms.new(Cliver.detect('pdftk'))
    Tempfile.new('concatenated-pdfs').tap do |tempfile|
      pdftk.cat(*pdfs, tempfile)
    end
  end

  def download_filename(conviction_events)
    full_name_for_filename = @user.full_name.gsub(/[^0-9A-Za-z]/, '_').downcase
    case_numbers_for_filename = conviction_events.map do |conviction_event|
      conviction_event.case_number.gsub(',', '_').gsub(/[^0-9A-Za-z]/, '')
    end.uniq

    ['cmr_petitions', full_name_for_filename].concat(case_numbers_for_filename).join('_') + '.pdf'
  end
end
