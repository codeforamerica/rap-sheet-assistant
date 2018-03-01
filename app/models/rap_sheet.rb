class RapSheet < ApplicationRecord
  belongs_to :user

  has_many :rap_sheet_pages

  DISMISSAL_STRATEGIES = [Prop64Classifier, PC1203Classifier]

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

  def dismissible_convictions
    DISMISSAL_STRATEGIES.flat_map { |strategy| dismissible_convictions_for_strategy(strategy) }.uniq
  end

  def potentially_dismissible_convictions
    DISMISSAL_STRATEGIES.flat_map { |strategy| potentially_dismissible_convictions_for_strategy(strategy) }.uniq
  end

  def dismissible_convictions_for_strategy(strategy)
    conviction_counts.select { |count| count.eligible?(user, strategy) }
  end

  def dismissible_convictions_exclusively_for_strategy(strategy)
    other_strategies = DISMISSAL_STRATEGIES - [strategy]
    conviction_counts.select do |count|
      count.eligible?(user, strategy) && !other_strategies.any? { |other_strategy| count.eligible?(user, other_strategy) }
    end
  end

  def potentially_dismissible_convictions_for_strategy(strategy)
    conviction_counts.select { |count| count.potentially_eligible?(user, strategy) }
  end

  def dismissible_conviction_events
    dismissible_convictions.map(&:event).uniq
  end

  def potentially_dismissible_conviction_events
    potentially_dismissible_convictions.map(&:event).uniq
  end

  def dismissible_conviction_events_for_strategy(strategy)
    events_with_convictions.select do |conviction_event|
      conviction_event.counts.any? { |count| count.eligible?(user, strategy) }
    end
  end

  def dismissible_conviction_events_exclusively_for_strategy(strategy)
    other_strategies = DISMISSAL_STRATEGIES - [strategy]
    events_with_convictions.select do |conviction_event|
      conviction_event.counts.any? do |count|
        count.eligible?(user, strategy) && !other_strategies.any? { |other_strategy| count.eligible?(user, other_strategy) }
      end
    end
  end

  def potentially_dismissible_conviction_events_for_strategy(strategy)
    events_with_convictions.select do |conviction_event|
      conviction_event.counts.any? { |count| count.potentially_eligible?(user, strategy) }
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
