class ConvictionSentenceBuilder
  def initialize(sentence_string)
    @sentence_string = sentence_string
  end

  def build
    str = sentence_string.split("\n").reject do |x|
      x.length <= 3
    end.join("\n")

    parts = str.
      downcase.
      gsub(/[.']/, '').
      gsub(/\n\s*/, ' ').
      gsub(/(restn|rstn)/, 'restitution').
      split(', ')

    probation = nil
    jail = nil
    prison = nil
    details = []

    parts.each do |p|
      match = p.match(/(\d+) (months|years|days)/)
      if match
        words = p.split(' ')
        amount = words[0].to_i
        unit = words[1][0]
        duration = duration(amount, unit)
        if words[2] == 'probation'
          probation = duration
        elsif words[2] == 'jail'
          jail = duration
        elsif words[2] == 'prison' && words[3] != 'ss'
          prison = duration
        end
      else
        details << p
      end
    end

    ConvictionSentence.new(
      probation: probation,
      jail: jail,
      prison: prison,
      details: details
    )
  end

  private

  attr_reader :sentence_string

  def duration(amount, unit)
    {
      'y' => amount.years,
      'm' => amount.months,
      'd' => amount.days
    }[unit]
  end
end
