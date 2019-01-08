class DocumentsController < ApplicationController
  def index
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    eligible_events = EligibilityChecker.new(@rap_sheet.parsed).eligible_events_with_counts

    @info_per_remedy = EligibilityChecker::REMEDIES.map do |remedy|
      {
        key: remedy[:key],
        name: remedy[:name],
        description_string: remedy[:description_string],
        events: eligible_events.reject { |e| e[remedy[:key]][:counts].empty? }
      }
    end
  end

  def download
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user
    eligibility = EligibilityChecker.new(@rap_sheet.parsed)

    petitions = create_petitions(eligibility)

    return redirect_to rap_sheet_documents_path(@rap_sheet) if petitions.empty?

    send_file concatenate_pdfs(petitions), filename: download_filename
  end

  def create_petitions(eligibility)
    result = []
    eligibility.eligible_events_with_counts.each do |eligible_event|
      EligibilityChecker::REMEDIES.each do |remedy|
        eligible_counts = eligible_event[remedy[:key]][:counts]
        if eligible_counts.present?
          result << remedy[:petition_creator].new(
            rap_sheet: @rap_sheet,
            conviction_event: eligible_event[:event],
            conviction_counts: eligible_counts,
            remedy_details: eligible_event[remedy[:key]][:remedy_details],
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
