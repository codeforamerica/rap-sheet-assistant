class SentenceParser
  def self.parse(sentence)
    sentence.split(', ').map do |s|
      match = s.match(/(\d+)(y|m|d) (probation|jail)/)
      if match
        amount = match[1].to_i
        unit = match[2]

        duration(amount, unit)
      end
    end.compact.sum
  end

  private

  def self.duration(amount, unit)
    {
      'y' => amount.years,
      'm' => amount.months,
      'd' => amount.days
    }[unit]
  end
end
