class ConvictionEventBuilder
  include EventBuilder

  def build
    conviction_event = ConvictionEvent.new(
      date: date,
      case_number: case_number,
      courthouse: courthouse,
      sentence: sentence
    )

    conviction_event.counts = event_syntax_node.conviction_counts.map do |count|
      ConvictionCountBuilder.new(conviction_event, count).build
    end

    conviction_event
  end

  private

  def case_number
    CaseNumberBuilder.build(event_syntax_node.case_number)
  end

  def courthouse
    CourthousePresenter.present(event_syntax_node.courthouse)
  end

  def sentence
    if event_syntax_node.sentence
      ConvictionSentenceBuilder.new(event_syntax_node.sentence.text_value).build
    end
  end
end
