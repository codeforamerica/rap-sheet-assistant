class RapSheetPdfController < ApplicationController
  def new
    render :new, locals: { file_persisted: false }
  end

  def create
    rap_sheet = RapSheet.new(user: User.new)
    
    Dir.mktmpdir do |dir|
      image_paths = ConvertPdfToImages.convert(rap_sheet_pdf_params[:pdf_file].path, dir)
      rap_sheet.number_of_pages = image_paths.length
      rap_sheet.save!
      image_paths.
        sort.
        each_with_index do |page, index|
        RapSheetPage.scan_and_create(
          image: File.new(page),
          rap_sheet: rap_sheet,
          page_number: index + 1
        )
      end
    end

    redirect_to rap_sheet_path(rap_sheet)
  end

  private

  def rap_sheet_pdf_params
    params.require(:rap_sheet_pdf).permit(:pdf_file)
  end
end
