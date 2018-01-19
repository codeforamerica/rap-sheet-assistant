class RapSheetPagesController < ApplicationController
  def create
    rap_sheet_id = find_or_create_rap_sheet_id

    RapSheetPage.scan_and_create(
      image: rap_sheet_page_params[:rap_sheet_page_image],
      rap_sheet_id: rap_sheet_id
    )

    redirect_to edit_rap_sheet_path(rap_sheet_id)
  end

  private

  def find_or_create_rap_sheet_id
    if rap_sheet_page_params[:rap_sheet_id].present?
      rap_sheet_page_params[:rap_sheet_id]
    else
      RapSheet.create!.id
    end
  end

  def rap_sheet_page_params
    params.require(:rap_sheet_page)
  end
end
