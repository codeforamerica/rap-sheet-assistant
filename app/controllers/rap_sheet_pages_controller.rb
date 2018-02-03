class RapSheetPagesController < ApplicationController
  def create
    rap_sheet = find_or_create_rap_sheet

    RapSheetPage.scan_and_create(
      image: rap_sheet_page_params[:rap_sheet_page_image],
      rap_sheet: rap_sheet
    )

    redirect_to edit_rap_sheet_path(rap_sheet)
  end

  private

  def find_or_create_rap_sheet
    if rap_sheet_page_params[:rap_sheet_id].present?
      RapSheet.find(rap_sheet_page_params[:rap_sheet_id])
    else
      RapSheet.create!
    end
  end

  def rap_sheet_page_params
    params.require(:rap_sheet_page)
  end
end
