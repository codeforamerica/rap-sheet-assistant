class ConvictionEvent
  def initialize(event_syntax_node, count_syntax_nodes)
    @event_syntax_node = event_syntax_node
    @counts = count_syntax_nodes.map do |count|
      ConvictionCount.new(self, count)
    end
  end

  def date
    Date.strptime(@event_syntax_node.date.text_value, '%Y%m%d')
  end

  def case_number
    CaseNumberPresenter.present(@event_syntax_node.case_number)
  end

  def courthouse
    CourthousePresenter.present(@event_syntax_node.courthouse)
  end

  def sentence
    SentencePresenter.present(@event_syntax_node.sentence)
  end

  attr_reader :counts
end
