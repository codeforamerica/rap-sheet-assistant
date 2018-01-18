class RapSheetPagesController < ApplicationController
  def create
    rap_sheet_page = RapSheetPage.scan_and_create(
      rap_sheet_page_params[:rap_sheet_page_image]
    )

    redirect_to rap_sheet_page_path(rap_sheet_page)
  end

  def show
    @rap_sheet_page = RapSheetPage.find(params[:id])
  end

  private

  def rap_sheet_page_params
    params.require(:rap_sheet_page)
  end
end
