class ConvictionSentence
  def initialize(probation: nil, jail: nil, prison: nil, details: nil)
    @probation = probation
    @jail = jail
    @details = details
    @prison = prison
  end

  attr_reader :probation, :jail, :prison

  def total_duration
    (jail ? jail : 0.days) + (probation ? probation : 0.days)
  end

  def to_s
    [probation_string, jail_string, *details].compact.join(', ')
  end

  private

  attr_reader :details

  def probation_string
    return unless probation

    p_k = probation.parts.keys[0]
    p_v = probation.parts[p_k]

    "#{p_v}#{p_k[0]} probation"
  end

  def jail_string
    return unless jail

    j_k = jail.parts.keys[0]
    j_v = jail.parts[j_k]

    "#{j_v}#{j_k[0]} jail"
  end
end
