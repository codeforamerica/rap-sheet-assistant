class RapSheetPagesController < ApplicationController
  def create
    RapSheetPage.create!(
      rap_sheet_page_image: rap_sheet_page_params[:rap_sheet_page_image]
    )

    flash[:notice] = 'Successfully uploaded!'
    redirect_to root_path
  end

  private

  def rap_sheet_page_params
    params.require(:rap_sheet_page)
  end
end
