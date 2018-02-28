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

  def events_with_convictions
    @events_with_convictions ||= begin
      parsed_tree = Parser.new.parse(text)
      RapSheetPresenter.present(parsed_tree)
    end
  end

  def conviction_counts
    events_with_convictions.flat_map(&:counts)
  end

  def num_convictions
    conviction_counts.length
  end

  def dismissible_convictions
    prop64_dismissible_convictions.concat(pc1203_dismissible_convictions).uniq
  end

  def potentially_dismissible_convictions
    prop64_dismissible_convictions.concat(pc1203_potentially_dismissible_convictions).uniq
  end

  def pc1203_potentially_dismissible_convictions
    conviction_counts.select(&:pc1203_potentially_eligible?)
  end

  def pc1203_dismissible_convictions
    conviction_counts.select(&:pc1203_eligible?)
  end

  def prop64_dismissible_convictions
    conviction_counts.select(&:prop64_eligible?)
  end

  def potentially_dismissible_conviction_events
    prop64_dismissible_conviction_events + pc1203_potentially_dismissible_conviction_events
  end

  def dismissible_conviction_events
    prop64_dismissible_conviction_events + pc1203_dismissible_conviction_events
  end

  def prop64_dismissible_conviction_events
    events_with_convictions.select do |conviction_event|
      conviction_event.counts.any?(&:prop64_eligible?)
    end
  end

  def pc1203_potentially_dismissible_conviction_events
    events_with_convictions.select do |conviction_event|
      conviction_event.counts.any?(&:pc1203_potentially_eligible?)
    end
  end

  def pc1203_dismissible_conviction_events
    events_with_convictions.select do |conviction_event|
      conviction_event.counts.any?(&:pc1203_eligible?)
    end
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
end
