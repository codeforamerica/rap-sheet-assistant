class ConvictionCountCollection
  include Enumerable

  DISMISSAL_STRATEGIES = [Prop64Classifier, PC1203Classifier]

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
