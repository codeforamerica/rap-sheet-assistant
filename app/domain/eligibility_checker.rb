class EligibilityChecker
  REMEDIES = [
    {
      key: :prop64,
      name: "Prop 64",
      classifier: Prop64Classifier,
      petition_creator: Prop64PetitionCreator
    },
    {
      key: :pc1203,
      name: "1203.4 dismissal",
      classifier: PC1203Classifier,
      petition_creator: PC1203PetitionCreator
    }
  ]

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
    result = {}
    for remedy in REMEDIES
      classifier = remedy[:classifier].new(event: event, rap_sheet: parsed_rap_sheet)
      result[remedy[:key]] = {
        counts: classifier.eligible_counts,
        remedy: classifier.remedy
      }
    end

    result
  end
end
