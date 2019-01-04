class EligibilityChecker
  def initialize(parsed_rap_sheet)
     @parsed_rap_sheet = parsed_rap_sheet
  end

  def all_eligible_counts
    all_counts = parsed_rap_sheet.convictions.map do |conviction_event|
      eligible_counts(conviction_event)
    end

    {
      prop64: all_counts.flat_map { |c| c[:prop64][:counts] },
      pc1203: all_counts.flat_map { |c| c[:pc1203][:counts] }
    }
  end

  def eligible?
    all_eligible_counts.any? { |key, value| value.present? }
  end

  def eligible_events_with_counts
   parsed_rap_sheet.convictions.map do |event|
      { event: event }.merge(eligible_counts(event))
    end
  end

  private

  attr_reader  :parsed_rap_sheet

  def eligible_counts(event)
    prop64_classifier = Prop64Classifier.new(event: event, rap_sheet: parsed_rap_sheet)
    prop64_counts = prop64_classifier.eligible_counts
    pc1203_classifier = PC1203Classifier.new(event: event, rap_sheet: parsed_rap_sheet)
    pc1203 =
      if pc1203_classifier.eligible?
        {
          counts: event.convicted_counts,
          remedy: pc1203_classifier.remedy
        }
      else
        {
          counts: [],
          remedy: nil
        }
      end

    {
      prop64: {
        counts: prop64_counts,
        remedy: prop64_classifier.remedy
      },
      pc1203: pc1203
    }
  end
end
