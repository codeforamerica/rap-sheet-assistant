class CourtDateParser
  def self.parse(text)
    sections = text.split('COURT:')

    sections_with_convictions = sections.select do |s|
      s.include?('DISPO:CONVICTED')
    end

    sections_with_convictions.map do |s|
      lines = s.split("\n").select do |l|
        !l.blank?
      end

      parse_date(lines[1][0..7])
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
