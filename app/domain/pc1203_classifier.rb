class PC1203Classifier
  def initialize(user, event)
    @user = user
    @event = event
  end

  def potentially_eligible?
    return false unless event.sentence

    !event.sentence.had_prison?
  end

  def eligible?
    return false if @user.on_parole
    return false if @user.on_probation
    return false if @user.outstanding_warrant

    potentially_eligible?
  end

  def remedy
    if event.sentence.had_probation?
      '1203.4'
    else
      case event.severity
        when 'M'
          '1203.4a'
        when 'I'
          '1203.4a'
        when 'F'
          '1203.41'
        else
          nil
      end
    end
  end

  private

  attr_reader :event
end
