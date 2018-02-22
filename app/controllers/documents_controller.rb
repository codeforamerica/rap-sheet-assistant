class DocumentsController < ApplicationController
  def index
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user
  end

  def download
    @rap_sheet = RapSheet.find(params[:rap_sheet_id])
    @user = @rap_sheet.user

    conviction_event = @rap_sheet.dismissible_conviction_events.first
    return redirect_to rap_sheet_documents_path(@rap_sheet) unless conviction_event

    send_file Prop64PetitionCreator.new(@rap_sheet, conviction_event).create_petition, filename: download_filename(conviction_event)
  end

  def download_filename(conviction_event)
    full_name_for_filename = @user.full_name.gsub(/[^0-9A-Za-z]/, '_')
    case_number_for_filename = conviction_event[:case_number].gsub(',', '_').gsub(/[^0-9A-Za-z]/, '')

    "prop64_petition_#{full_name_for_filename}_#{case_number_for_filename}.pdf"
  end
end
