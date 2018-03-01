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
    ConvictionCountCollection.new(user, events_with_convictions.flat_map(&:counts))
  end

  def first_missing_page_number
    ((1..number_of_pages).to_a - rap_sheet_pages.pluck(:page_number)).first
  end

  def all_pages_uploaded?
    rap_sheet_pages.length == number_of_pages
  end
  
  private
  
  class ConvictionCountCollection
    include Enumerable

    def initialize(user, conviction_counts)
      @user = user
      @conviction_counts = conviction_counts
    end

    delegate :length, :count, :present?, :each, to: :@conviction_counts

    def events
      @conviction_counts.map(&:event).uniq
    end

    def dismissible
      filtered_collection(
        DISMISSAL_STRATEGIES.flat_map do |strategy|
          dismissible_by_strategy(strategy).to_a
        end.uniq
      )
    end

    def dismissible_by_strategy(strategy)
      filtered_collection(
        @conviction_counts.select { |count| count.eligible?(@user, strategy) }
      )
    end

    def dismissible_exclusively_by_strategy(strategy)
      other_strategies = DISMISSAL_STRATEGIES - [strategy]
      filtered_collection(
        @conviction_counts.select do |count|
          count.eligible?(@user, strategy) && !other_strategies.any? { |other_strategy| count.eligible?(@user, other_strategy) }
        end
      )
    end

    def potentially_dismissible
      filtered_collection(
        DISMISSAL_STRATEGIES.flat_map do |strategy|
          potentially_dismissible_by_strategy(strategy).to_a
        end.uniq
      )
    end

    def potentially_dismissible_by_strategy(strategy)
      filtered_collection(
        @conviction_counts.select { |count| count.potentially_eligible?(@user, strategy) }
      )
    end

    def severity_felony
      with_severity('F')
    end

    def severity_misdemeanor
      with_severity('M')
    end

    def severity_unknown
      with_severity(nil)
    end

    private

    def with_severity(severity)
      filtered_collection(
        @conviction_counts.select { |count| count.severity == severity }
      )
    end

    def filtered_collection(filtered_conviction_counts)
      self.class.new(@user, filtered_conviction_counts)
    end
  end
end
