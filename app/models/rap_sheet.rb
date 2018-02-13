class RapSheet < ApplicationRecord
  has_many :rap_sheet_pages

  validates :number_of_pages, numericality: {
    only_integer: true,
    less_than: 100,
    greater_than_or_equal_to: 1
  }

  def text
    rap_sheet_pages.map(&:text).join
  end

  def convictions
    RapSheetPresenter.present(parsed_tree)[:convictions]
  end

  private

  def parsed_tree
    @parsed_tree ||= Parser.new.parse(text)
  end
end
