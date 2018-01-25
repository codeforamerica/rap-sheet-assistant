class RapSheetPage < ApplicationRecord
  mount_uploader :rap_sheet_page_image, RapSheetPageImageUploader
  default_scope { order(created_at: :asc) }

  def self.scan_and_create(image:, rap_sheet_id:)
    RapSheetPage.create!(
      rap_sheet_page_image: image,
      rap_sheet_id: rap_sheet_id,
      text: TextScanner.scan_text(image.path),
    )
  end
end
