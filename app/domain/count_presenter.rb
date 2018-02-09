class CountPresenter
  def self.present(count)
    {
        code_section: format_code_section(count),
        code_section_description: format_code_section_description(count)
    }
  end

  private

  def self.format_code_section(count)
    if count.code_section
      "#{count.code_section.code.text_value} #{count.code_section.number.text_value.delete(' ')}"
    else
      #check comments for charge
      ''
    end
  end

  def self.format_code_section_description(count)
    if count.code_section_description
      count.code_section_description.text_value.chomp
    else
      #check comments for charge
      ''
    end
  end
end
