class RapSheet < ApplicationRecord
  has_many :rap_sheet_pages

  def text
    rap_sheet_pages.map(&:text).join
  end

  def convictions
    CourtDateParser.parse(text)
  end
end
