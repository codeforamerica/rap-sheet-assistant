class PC1203Classifier
  include Classifier

  def potentially_eligible?
    return false unless event.sentence

    !event.sentence.prison
  end

  def eligible?
    return false if @user.on_parole
    return false if @user.on_probation
    return false if @user.outstanding_warrant

    potentially_eligible?
  end

  def remedy
    if event.sentence.probation
      code = '1203.4'
      probation_successful = event.successfully_completed_probation?(event_collection)

      scenario =
        if probation_successful
          :successful_completion
        elsif probation_successful == false
          :discretionary
        else
          :unknown
        end
    else
      code =
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
      scenario = nil
    end

    return nil if code.nil?

    {
      code: code,
      scenario: scenario
    }
  end
end
