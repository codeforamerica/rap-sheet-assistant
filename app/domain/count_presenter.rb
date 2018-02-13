class CountPresenter
  def self.present(count)
    {
        code_section: format_code_section(count),
        code_section_description: format_code_section_description(count),
        severity: format_severity(count)
    }
  end

  private

  def self.format_code_section(count)
    "#{count.code_section.code.text_value} #{format_code_section_number(count)}" if count.code_section
  end

  def self.format_code_section_number(count)
    count.code_section.number.text_value.delete(' ').gsub(',','.')
  end

  def self.format_code_section_description(count)
    count.code_section_description.text_value.chomp if count.code_section_description
  end

  def self.format_severity(count)
    if count.disposition.is_a? CountGrammar::Convicted
      if count.disposition.severity
        count.disposition.severity.text_value[0]
      end
    end
  end
end
