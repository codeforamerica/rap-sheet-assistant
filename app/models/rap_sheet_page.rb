class RapSheetPage < ApplicationRecord
  belongs_to :rap_sheet

  validates_presence_of :page_number
  validates_uniqueness_of :page_number, scope: [:rap_sheet_id]
  validates :page_number, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  mount_uploader :rap_sheet_page_image, RapSheetPageImageUploader
  default_scope { order(page_number: :asc) }

  def self.scan_and_create(image:, rap_sheet:, page_number:)
    RapSheetPage.create!(
      rap_sheet_page_image: image,
      rap_sheet: rap_sheet,
      page_number: page_number,
      text: TextScanner.scan_text(image.path),
    )
  end
end
