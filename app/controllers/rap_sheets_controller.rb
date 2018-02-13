class RapSheetsController < ApplicationController
  def index
    @rap_sheet = RapSheet.new
  end

  def edit
    @rap_sheet_id = params[:id]
    @rap_sheet_page = RapSheetPage.new(
      rap_sheet_id: params[:id]
    )
  end

  def show
    @rap_sheet = RapSheet.find(params[:id])
  end

  def create
    @rap_sheet = RapSheet.new(rap_sheet_params)
    if @rap_sheet.save
      redirect_to edit_rap_sheet_path(@rap_sheet)
    else
      render :index
    end
  end

  private

  def rap_sheet_params
    params.require(:rap_sheet).permit(:number_of_pages)
  end
end
