class RapSheetsController < ApplicationController
  def index
    @rap_sheet_page = RapSheetPage.new
  end
end
