class EligibilityChecker
  REMEDIES = [
    {
      key: :prop64,
      name: "Prop 64",
      classifier: Prop64Classifier,
      petition_creator: Prop64PetitionCreator
    },
    {
      key: :pc1203_mandatory,
      name: "1203.4 mandatory",
      classifier: PC1203MandatoryClassifier,
      petition_creator: PC1203PetitionCreator
    },
    {
      key: :pc1203_discretionary,
      name: "1203.4 discretionary",
      classifier: PC1203DiscretionaryClassifier,
      petition_creator: PC1203PetitionCreator
    },
    {
      key: :prop47,
      name: "Prop 47",
      classifier: Prop47Classifier,
      petition_creator: Prop47PetitionCreator
    }
  ]

  def initialize(parsed_rap_sheet)
    @parsed_rap_sheet = parsed_rap_sheet
  end

  def all_eligible_counts
    all_counts = parsed_rap_sheet.convictions.map do |conviction_event|
      eligible_counts(conviction_event)
    end
    result = {}
    REMEDIES.each do |remedy|
      key = remedy[:key]
      result[key] = all_counts.flat_map { |c| c[key][:counts] }
    end
    result
  end

  def eligible?
    all_eligible_counts.any? { |key, value| value.present? }
  end

  def eligible_events_with_counts
    parsed_rap_sheet.convictions.map do |event|
      { event: event }.merge(eligible_counts(event))
    end
  end

  def eligiblity_for_count(event, count)
    result = []
    eligible_counts = eligible_counts(event)
    for remedy, info in eligible_counts
      if info[:counts].include?(count)
        result << { remedy: remedy, remedy_details: info[:remedy_details] }
      end
    end
    result
  end

  private

  attr_reader :parsed_rap_sheet

  def eligible_counts(event)
    result = {}
    for remedy in REMEDIES
      classifier = remedy[:classifier].new(event: event, rap_sheet: parsed_rap_sheet)
      result[remedy[:key]] = {
        counts: classifier.eligible_counts,
        remedy_details: classifier.remedy_details
      }
    end

    result
  end
end
