class PC1203Classifier
  include Classifier

  def eligible?
    return false unless event.sentence
    return false unless event.date

    code = remedy_details_hash[:code]
    if code == '1203.4'
      return true if event.date < Date.today - event.sentence.total_duration
    elsif code == '1203.4a'
      return true if event.date < Date.today - 1.year
    elsif code == '1203.41'
      return true if !event.sentence.prison && event.date < Date.today - event.sentence.total_duration - 2.year
    end

    false
  end

  def remedy_details
    if eligible?
      remedy_details_hash
    else
      nil
    end
  end

  def discretionary?
    r = remedy_details_hash
    return nil if r.empty?
    r[:code] == '1203.41' || r[:scenario] == :discretionary
  end

  def eligible_counts
    if eligible?
      event.convicted_counts
    else
      []
    end
  end

  private

  def scenario_for_code(code)
    if code == '1203.4'
      success =  !event.probation_violated?(rap_sheet)
    elsif code == '1203.4a'
      success = event.successfully_completed_duration?(rap_sheet, 1.year)
    else
      return nil
    end
    return :unknown if event.date.nil? || success.nil?
    success ? :successful_completion : :discretionary
  end

  def remedy_details_hash
    return {} unless event.sentence

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

    return {} if code.nil?

    {
      code: code,
      scenario: scenario_for_code(code)
    }
  end
end
