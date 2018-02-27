class Count
  def initialize(presented_event, count_syntax_node)
    @code_section = format_code_section(count_syntax_node)
    @code_section_description = format_code_section_description(count_syntax_node)
    @severity = format_severity(count_syntax_node)
    @event = presented_event
  end

  attr_reader :event, :code_section, :code_section_description, :severity

  def prop64_eligible?
    Prop64Classifier.new(self).eligible?
  end

  def prop64_action
    Prop64Classifier.new(self).action
  end

  def pc1203_eligible?
    PC1203Classifier.new(self).eligible?
  end

  def pc1203_potentially_eligible?
    PC1203Classifier.new(self).potentially_eligible?
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
