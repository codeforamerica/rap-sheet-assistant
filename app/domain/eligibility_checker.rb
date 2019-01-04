class EligibilityChecker
  REMEDIES = [
    {
      key: :prop64,
      name: "Prop 64",
      description_string: 'clear these marijuana convictions',
      details_page_toc_string: 'marijuana conviction',
      details_page_remedy_string: 'reclassify',
      details_page_if_judge_approval: 'reduced to misdemeanors or',
      classifier: Prop64Classifier,
      petition_creator: Prop64PetitionCreator
    },
    {
      key: :pc1203,
      name: "1203.4 mandatory dismissal",
      description_string: 'dismiss these convictions',
      details_page_toc_string: 'conviction',
      details_page_remedy_string: 'dismiss',
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
    result = {}
    REMEDIES.each do |remedy|
     key = remedy[:key]
     result[key] =  all_counts.flat_map { |c| c[key][:counts] }
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
