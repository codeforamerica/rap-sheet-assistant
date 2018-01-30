class CourtDateParser
  def self.parse(text)
    text = self.cleaned_up(text)

    if text.index('COURT')
      text = text[text.index('COURT')..-1]
    end
    sections = text.split(/COURT ?:.*\n/)

    sections_with_convictions = sections.select do |s|
      s[/DISPO ?: ?CONVICTED/]
    end

    sections_with_convictions.map do |s|
      {
        date: parse_date(s[/\d{8}/]),
        case_number: parse_case_number(s)
      }
    end
  end

  private
  def self.parse_case_number(s)
    return nil unless s.include?('#')

    case_number = s[/#.+\n/].split('#')[1].strip.delete(' ').delete('.')

    self.strip_trailing_punctuation(case_number)
  end

  def self.parse_date(date_string)
    Date.strptime(date_string, '%Y%m%d')
  rescue
    puts "Unable to parse date: #{date_string}"
    nil
  end

  def self.cleaned_up(text)
    text.gsub('–','-')
  end

  def self.strip_trailing_punctuation(str)
    new_str = str

    while new_str.end_with?('.', ':')
      new_str = new_str[0..-2]
    end
    new_str
  end
end
