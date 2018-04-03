class EligibilityDeterminer
  def initialize(user)
    @user = user
  end

  def all_eligible_counts
    all_counts = events.map do |conviction_event|
      eligible_counts(conviction_event)
    end

    {
      prop64: ConvictionCountCollection.new(all_counts.flat_map { |c| c[:prop64][:counts] }),
      pc1203: ConvictionCountCollection.new(all_counts.flat_map { |c| c[:pc1203][:counts] })
    }
  end

  def eligible?
    all_eligible_counts.any? { |key, value| value.present? }
  end

  def potentially_eligible?
    all_potentially_eligible_counts.any? { |key, value| value.present? }
  end

  def all_potentially_eligible_counts
    all_counts = events.map do |conviction_event|
      potentially_eligible_counts(conviction_event)
    end

    {
      prop64: ConvictionCountCollection.new(all_counts.flat_map { |c| c[:prop64][:counts] }),
      pc1203: ConvictionCountCollection.new(all_counts.flat_map { |c| c[:pc1203][:counts] })
    }
  end

  def eligible_events_with_counts
    events.map do |event|
      { event: event }.merge(eligible_counts(event))
    end
  end

  def needs_1203_info?
    !all_potentially_eligible_counts[:pc1203].empty?
  end

  private

  attr_reader :user

  def eligible_counts(event)
    prop64_counts = Prop64Classifier.new(user, event).eligible_counts
    pc1203_classifier = PC1203Classifier.new(@user, event)
    pc1203 =
      if pc1203_classifier.eligible?
        {
          counts: event.counts - prop64_counts,
          remedy: pc1203_classifier.remedy
        }
      else
        {
          counts: ConvictionCountCollection.new([]),
          remedy: nil
        }
      end

    {
      prop64: {
        counts: prop64_counts
      },
      pc1203: pc1203
    }
  end

  def potentially_eligible_counts(event)
    prop64_counts = Prop64Classifier.new(user, event).potentially_eligible_counts
    pc1203_counts =
      if PC1203Classifier.new(@user, event).potentially_eligible?
        event.counts - prop64_counts
      else
        ConvictionCountCollection.new([])
      end

    {
      prop64: {
        counts: prop64_counts
      },
      pc1203: {
        counts: pc1203_counts,
      }
    }
  end

  def events
    @events ||= user.rap_sheet.events.with_convictions
  end
end
