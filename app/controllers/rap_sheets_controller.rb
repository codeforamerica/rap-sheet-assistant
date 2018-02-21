class RapSheetsController < ApplicationController
  def index
    @rap_sheet = RapSheet.new
  end

  def edit
    @rap_sheet = RapSheet.find(params[:id])

    @rap_sheet_pages = (1..@rap_sheet.number_of_pages).map do |n|
      RapSheetPage.find_or_initialize_by(
        page_number: n,
        rap_sheet: @rap_sheet
      )
    end
  end

  def show
    @rap_sheet = RapSheet.find(params[:id])
  end

  def create
    @rap_sheet = RapSheet.new(rap_sheet_params.merge(user: User.new))
    if @rap_sheet.save
      redirect_to edit_rap_sheet_path(@rap_sheet)
    else
      render :index
    end
  end

  def debug
    @rap_sheet = RapSheet.find(params[:id])
  end

  def details
    @rap_sheet = RapSheet.find(params[:id])
  end

  def documents
    @rap_sheet = RapSheet.find(params[:id])
    @user = @rap_sheet.user
  end

  def add_page
    @rap_sheet = RapSheet.find(params[:id])
    @rap_sheet.update(number_of_pages: @rap_sheet.number_of_pages + 1)

    redirect_to edit_rap_sheet_path(@rap_sheet)
  end

  def remove_page
    @rap_sheet = RapSheet.find(params[:id])

    if @rap_sheet.number_of_pages > 1
      last_page = @rap_sheet.rap_sheet_pages.find_by(page_number: @rap_sheet.number_of_pages)
      last_page.destroy if last_page

      @rap_sheet.update!(number_of_pages: @rap_sheet.number_of_pages - 1)
    end

    redirect_to edit_rap_sheet_path(@rap_sheet)
  end

  private

  def rap_sheet_params
    params.require(:rap_sheet).permit(:number_of_pages)
  end
end
