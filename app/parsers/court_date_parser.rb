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

      lines[1][0..7]
    end
  end
end
