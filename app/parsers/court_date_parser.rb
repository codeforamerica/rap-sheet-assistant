class CourtDateParser
  def self.parse(text)
    lines = text.split("\n")

    indices = []
    lines.each.with_index do |line, i|
      if line.include?('COURT:')
        indices << i
      end
    end

    dates = indices.map do |i|
      lines[i+1][0..8]
    end

    return dates.map do |d|
      Date.strptime(d, '%Y%m%d')
    end
  end
end
