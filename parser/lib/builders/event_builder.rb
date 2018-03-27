module EventBuilder
  def initialize(event_syntax_node)
    @event_syntax_node = event_syntax_node
  end

  private

  attr_reader :event_syntax_node

  def date
    Date.strptime(event_syntax_node.date.text_value, '%Y%m%d')
  rescue ArgumentError
    nil
  end
end
