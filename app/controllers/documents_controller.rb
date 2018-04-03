class DocumentsController < ApplicationController
  def index
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @eligible_counts = EligibilityDeterminer.new(@rap_sheet.user).all_eligible_counts
  end

  def download
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user
    eligibility = EligibilityDeterminer.new(@rap_sheet.user)

    petitions = create_petitions(eligibility)

    return redirect_to rap_sheet_documents_path(@rap_sheet) if petitions.empty?

    send_file concatenate_pdfs(petitions), filename: download_filename
  end

  def create_petitions(eligibility)
    result = []

    eligibility.eligible_events_with_counts.each do |eligible_event|
      prop64_counts = eligible_event[:prop64][:counts]
      pc1203_counts = eligible_event[:pc1203][:counts]
      if prop64_counts.present?
        result << Prop64PetitionCreator.new(@rap_sheet, eligible_event[:event], prop64_counts).create_petition
      end

      if pc1203_counts.present?
        if pc1203_counts.present?
          result << PC1203PetitionCreator.new(
            rap_sheet: @rap_sheet,
            conviction_event: eligible_event[:event],
            conviction_counts: pc1203_counts,
            remedy: eligible_event[:pc1203][:remedy]
          ).create_petition
        end
      end
    end

    result << FeeWaiverPetitionCreator.new(@rap_sheet.user).create_petition

    result
  end

  def concatenate_pdfs(pdfs)
    pdftk = PdfForms.new(Cliver.detect('pdftk'))
    Tempfile.new('concatenated-pdfs').tap do |tempfile|
      pdftk.cat(*pdfs, tempfile)
    end
  end

  def download_filename
    full_name_for_filename = @user.full_name.gsub(/[^0-9A-Za-z]/, '_').downcase
    ['cmr_petitions', full_name_for_filename, Date.today].join('_') + '.pdf'
  end
end
