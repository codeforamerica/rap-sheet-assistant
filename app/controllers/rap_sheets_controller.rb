class RapSheetsController < ApplicationController
  def index
    @rap_sheet = RapSheet.new
  end

  def edit
    @rap_sheet = RapSheet.find(params[:id])

    @rap_sheet_page = @rap_sheet.rap_sheet_pages.build(
      page_number: @rap_sheet.rap_sheet_pages.count + 1
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

  def debug
    @rap_sheet = RapSheet.find(params[:id])
  end

  def completed
    @rap_sheet = RapSheet.find(params[:id])
  end

  private

  def rap_sheet_params
    params.require(:rap_sheet).permit(:number_of_pages)
  end
end
