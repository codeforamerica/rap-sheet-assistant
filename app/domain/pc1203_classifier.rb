class PC1203Classifier
  include Classifier

  def potentially_eligible?
    return false unless event.sentence
    return false unless event.date
    return false if event.date > Date.today - 1.year

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
    end

    return nil if code.nil?

    {
      code: code,
      scenario: scenario_for_code(code)
    }
  end

  private

  def scenario_for_code(code)
    if code == '1203.4'
      probation_successful = event.successfully_completed_probation?(event_collection)
      if probation_successful
        :successful_completion
      elsif probation_successful == false
        :discretionary
      else
        :unknown
      end
    elsif code == '1203.4a'
      year_successful = event.successfully_completed_year?(event_collection)
      if year_successful
        :successful_completion
      elsif year_successful == false
        :discretionary
      else
        :unknown
      end
    else
      nil
    end
  end
end
