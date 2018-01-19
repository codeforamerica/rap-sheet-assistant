class RapSheetsController < ApplicationController
  def index
    @rap_sheet_page = RapSheetPage.new
  end

  def edit
    @rap_sheet_id = params[:id]
    @rap_sheet_page = RapSheetPage.new(
      rap_sheet_id: params[:id]
    )
  end

  def show
    @rap_sheet = RapSheet.find(params[:id])

    @court_dates = CourtDateParser.parse(
      @rap_sheet.rap_sheet_pages.map(&:text).join
    )
  end
end
