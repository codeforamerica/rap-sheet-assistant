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
    parsed_rap_sheet[:events_with_convictions]
  end

  def conviction_counts
    parsed_rap_sheet[:conviction_counts]
  end

  def num_convictions
    conviction_counts.length
  end

  def dismissible_convictions
    conviction_counts.select(&:prop64_eligible?)
  end

  def num_felonies
    conviction_counts.select { |count| count.severity == 'F' }.length
  end

  def num_misdemeanors
    conviction_counts.select { |count| count.severity == 'M' }.length
  end

  def num_unknown
    conviction_counts.select { |count| count.severity == nil }.length
  end

  def first_missing_page_number
    ((1..number_of_pages).to_a - rap_sheet_pages.pluck(:page_number)).first
  end

  def all_pages_uploaded?
    rap_sheet_pages.length == number_of_pages
  end

  private

  def parsed_rap_sheet
    @parsed_rap_sheet ||= begin
      parsed_tree = Parser.new.parse(text)
      RapSheetPresenter.present(parsed_tree)
    end
  end
end
