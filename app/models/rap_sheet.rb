class RapSheet < ApplicationRecord
  has_many :rap_sheet_pages

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
