class RapSheetPage < ApplicationRecord
  belongs_to :rap_sheet

  mount_uploader :rap_sheet_page_image, RapSheetPageImageUploader
  default_scope { order(page_number: :asc) }

  def self.scan_and_create(image:, rap_sheet:)
    RapSheetPage.create!(
      rap_sheet_page_image: image,
      rap_sheet: rap_sheet,
      page_number: rap_sheet.rap_sheet_pages.count,
      text: TextScanner.scan_text(image.path),
    )
  end
end
