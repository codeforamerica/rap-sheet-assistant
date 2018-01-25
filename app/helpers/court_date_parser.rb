class CourtDateParser
  def self.parse(text)
    sections = text.split(/COURT ?:.*\n/)

    sections_with_convictions = sections.select do |s|
      s[/CONVICTED/]
    end

    sections_with_convictions.map do |s|
      parse_date(s[/\d{8}/])
    end
  end

  private

  def self.parse_date(date_string)
    Date.strptime(date_string, '%Y%m%d')
  rescue
    puts "Unable to parse date: #{date_string}"
    nil
  end
end
