class ConvictionEvent
  def initialize(event_syntax_node, count_syntax_nodes)
    @date = format_date(event_syntax_node)
    @case_number = format_case_number(event_syntax_node)
    @courthouse = format_courthouse(event_syntax_node)
    sentence_string = event_syntax_node.sentence.try(:text_value)
    @sentence = ConvictionSentence.new(sentence_string) if sentence_string
    @counts = count_syntax_nodes.map do |count|
      ConvictionCount.new(self, count)
    end
  end

  def inspect
    OkayPrint.new(self).exclude_ivars(:@counts).inspect
  end

  attr_reader :counts, :date, :case_number, :courthouse, :sentence

  private

  def format_date(event_syntax_node)
    Date.strptime(event_syntax_node.date.text_value, '%Y%m%d')
  end

  def format_case_number(event_syntax_node)
    CaseNumberPresenter.present(event_syntax_node.case_number)
  end

  def format_courthouse(event_syntax_node)
    CourthousePresenter.present(event_syntax_node.courthouse)
  end
end
