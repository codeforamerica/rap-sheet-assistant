require 'csv'

class DocumentsController < ApplicationController
  def index
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
  end

  def download
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user
    eligibility = EligibilityChecker.new(@rap_sheet.parsed)

    petitions = create_petitions(eligibility)

    return redirect_to rap_sheet_documents_path(@rap_sheet) if petitions.empty?

    send_file concatenate_pdfs(petitions), filename: download_filename
  end

  def download_summary
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user
    eligibility = EligibilityChecker.new(@rap_sheet.parsed)

    send_data create_summary_csv(eligibility), filename: summary_filename
  end

  private

  def create_petitions(eligibility)
    result = []
    eligibility.eligible_events_with_counts.each do |eligible_event|
      EligibilityChecker::REMEDIES.each do |remedy|
        eligible_counts = eligible_event[remedy[:key]][:counts]
        if eligible_counts.present? && remedy[:petition_creator]
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
    full_name_for_filename = @user.name.tr(" ", "_").downcase
    ['cmr_petitions', full_name_for_filename, Date.today].join('_') + '.pdf'
  end

  def create_summary_csv(eligibility)
    CSV.generate(headers: true) do |csv|
      csv << ["type", "chron order", "date", "case number", "code section", "description", "severity", "probation", "jail/prision", "remedy", "notes"]

      convictions = @rap_sheet.parsed.convictions
      out_of_county_convictions = []

      csv << ["-", "-", "-", "SANTA CLARA COUNTY", "-", "-", "-", "-", "-", "-", "-"]
      convictions.each do |event|
        if [].include?(event.courthouse)
          csv << csv_row(event)
        else
          out_of_county_convictions << event
        end
      end

      csv << ["-", "-", "-", "OTHER COUNTIES", "-", "-", "-", "-", "-", "-", "-"]
      out_of_county_convictions.each do |event|
        csv << csv_row(event)
      end
    end
  end

  def summary_filename
    full_name_for_filename = @user.name.tr(" ", "_").downcase
    ['rap_sheet_summary', full_name_for_filename, Date.today].join('_') + '.csv'
  end

  def csv_row(event)
    ["?", "1",event.date, event.case_number]
  end
end
