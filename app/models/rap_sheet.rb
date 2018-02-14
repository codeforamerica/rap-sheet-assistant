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
    RapSheetPresenter.present(parsed_tree)[:events_with_convictions]
  end

  def conviction_counts
    RapSheetPresenter.present(parsed_tree)[:conviction_counts]
  end

  def num_convictions
    conviction_counts.length
  end

  def num_felonies
    conviction_counts.select { |count| count[:severity] == 'F' }.length
  end

  def num_misdemeanors
    conviction_counts.select { |count| count[:severity] == 'M' }.length
  end

  def num_unknown
    conviction_counts.select { |count| count[:severity] == nil }.length
  end

  private

  def parsed_tree
    @parsed_tree ||= Parser.new.parse(text)
  end
end
