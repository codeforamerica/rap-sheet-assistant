class ConvictionSentence
  def initialize (sentence_string)
    @sentence_string = sentence_string
  end

  def total_duration
    @sentence_string.split(', ').map do |s|
      match = s.match(/(\d+)(y|m|d) (probation|jail)/)
      if match
        amount = match[1].to_i
        unit = match[2]

        self.class.duration(amount, unit)
      end
    end.compact.sum
  end

  def had_probation?
    had_sentence_type('probation')
  end

  def had_jail?
    had_sentence_type('jail')
  end

  def had_prison?
    had_sentence_type('prison') && !had_sentence_type('prison ss')
  end

  def to_s
    return unless @sentence_string

    parts = @sentence_string.
      downcase.
      gsub(/[.']/, '').
      gsub(/\n\s*/, ' ').
      split(', ')

    parts.map do |p|
      p.gsub(/(\d+) (months|years|days)/) do |match|
        words = match.split(' ')
        "#{words[0].to_i}#{words[1][0]}"
      end.gsub(/(restn|rstn)/, 'restitution')
    end.join(', ')
  end

  private

  def had_sentence_type(type)
    @sentence_string.split(',').any? do |sentence_component|
      sentence_component.downcase.strip.match(/#{type}/)
    end
  end

  def self.duration(amount, unit)
    {
      'y' => amount.years,
      'm' => amount.months,
      'd' => amount.days
    }[unit]
  end
end
