class ConvictionSentenceBuilder
  def initialize(sentence_node)
    @sentence_node = sentence_node
  end

  def build
    ConvictionSentence.new(
      probation: duration(sentence_node.probation),
      jail: duration(sentence_node.jail),
      prison: duration(sentence_node.prison),
      details: details
    )
  end

  private

  attr_reader :sentence_node

  def details
    sentence_node.details.map do |s|
      s.text_value.
        downcase.
        gsub(/(restn|rstn)/, 'restitution')
    end
  end

  def duration(node)
    return unless node

    words = node.text_value.split(' ')
    amount = words[0].to_i
    unit = words[1][0]

    {
      'Y' => amount.years,
      'M' => amount.months,
      'D' => amount.days
    }[unit]
  end
end
