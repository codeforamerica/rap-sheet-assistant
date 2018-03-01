class ConvictionCount
  def initialize(conviction_event, count_syntax_node)
    @code_section = format_code_section(count_syntax_node)
    @code_section_description = format_code_section_description(count_syntax_node)
    @severity = format_severity(count_syntax_node)
    @event = conviction_event
  end

  def inspect
    OkayPrint.new(self).exclude_ivars(:@event).inspect
  end

  attr_reader :event, :code_section, :code_section_description, :severity

  def eligible?(user, classifier)
    classifier.new(user, self).eligible?
  end

  def potentially_eligible?(user, classifier)
    classifier.new(user, self).potentially_eligible?
  end

  private

  def format_code_section(count)
    "#{count.code_section.code.text_value} #{format_code_section_number(count)}" if count.code_section
  end

  def format_code_section_number(count)
    count.code_section.number.text_value.delete(' ').gsub(',', '.')
  end

  def format_code_section_description(count)
    count.code_section_description.text_value.chomp if count.code_section_description
  end

  def format_severity(count)
    if count.disposition.is_a? CountGrammar::Convicted
      if count.disposition.severity
        count.disposition.severity.text_value[0]
      end
    end
  end
end
