class RapSheet < ApplicationRecord
  belongs_to :user

  has_many :rap_sheet_pages

  validates :number_of_pages, numericality: {
    only_integer: true,
    less_than: 100,
    greater_than_or_equal_to: 1
  }

  def text
    rap_sheet_pages.map(&:text).join
  end

  def conviction_counts
    events.with_convictions.conviction_counts(user)
  end

  def first_missing_page_number
    ((1..number_of_pages).to_a - rap_sheet_pages.pluck(:page_number)).first
  end

  def all_pages_uploaded?
    rap_sheet_pages.length == number_of_pages
  end

  def events
    @events ||= begin
      parsed_tree = Parser.new.parse(text)
      EventCollectionBuilder.build(parsed_tree)
    end
  end
end
