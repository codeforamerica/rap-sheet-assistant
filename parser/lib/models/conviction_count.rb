class ConvictionCount
  def initialize(event:, code_section_description:, severity:, code:, section:)
    @section = section
    @code = code
    @severity = severity
    @code_section_description = code_section_description
    @event = event
  end

  def inspect
    OkayPrint.new(self).exclude_ivars(:@event).inspect
  end

  attr_reader :event, :code_section_description, :severity, :code, :section

  def eligible?(user, classifier)
    classifier.new(user, self).eligible?
  end

  def potentially_eligible?(user, classifier)
    classifier.new(user, self).potentially_eligible?
  end

  def long_severity
    case severity
      when 'F'
        'felony'
      when 'M'
        'misdemeanor'
      when 'I'
        'infraction'
      else
        'unknown'
    end
  end

  def code_section
    return unless code && section
    "#{code} #{section}"
  end
end
