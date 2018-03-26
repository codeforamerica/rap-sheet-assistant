class ConvictionEventBuilder
  def initialize(event_syntax_node)
    @event_syntax_node = event_syntax_node
  end

  def build
    conviction_event = ConvictionEvent.new(
      date: date,
      case_number: case_number,
      courthouse: courthouse,
      sentence: sentence
    )

    conviction_event.counts = event_syntax_node.conviction_counts.map do |count|
      ConvictionCount.new(conviction_event, count)
    end

    conviction_event
  end

  private

  attr_reader :event_syntax_node

  def date
    Date.strptime(event_syntax_node.date.text_value, '%Y%m%d')
  end

  def case_number
    CaseNumberPresenter.present(event_syntax_node.case_number)
  end

  def courthouse
    CourthousePresenter.present(event_syntax_node.courthouse)
  end

  def sentence
    sentence_string = event_syntax_node.sentence.try(:text_value)
    ConvictionSentence.new(sentence_string) if sentence_string
  end
end
