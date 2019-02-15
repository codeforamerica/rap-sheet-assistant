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

  def dui?(count)
    DUI_CODE_SECTIONS.any? { |code_section| count.code_section.match(code_section)}
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
    return :discretionary if event.counts.any?{ |count| dui?(count) }
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

DUI_CODE_SECTIONS = [
# 'VC 23152',
 /(VC)+\s*(23152)/,

# 'VC 20001',
 /(VC)+\s*(20001)/,

# 'VC 20002',
 /(VC)+\s*(20002)/,

# 'VC 23153',
 /(VC)+\s*(23153)/,

# 'PC 191.5',
 /(PC)+\s*(191.5)/,

# 'PC 192(c)',
 /(PC)+\s*(192)\(*c\)*/,

# 'VC 2800.2',
 /(VC)+\s*(2800.2)/,

# 'VC 2800.3',
 /(VC)+\s*(2800.3)/,

# 'VC 21651(b)',
 /(VC)+\s*(21651)\(*b\)/,

# 'VC 22348(b)',
 /(VC)+\s*(22348)\(*b\)/,

# 'VC 23109(a)',
 /(VC)+\s*(23109)\(*a\)/,

# 'VC 23109(c)',
 /(VC)+\s*(23109)\(*c\)/,

# 'VC 31602',
 /(VC)+\s*(31602)/,

# 'VC 23140(a)',
 /(VC)+\s*(23140)\(*a\)/,

# 'VC 23140(b)',
 /(VC)+\s*(23140)\(*b\)/,

# 'VC 14601',
 /(VC)+\s*(14601)/,

# 'VC 14601.1',
 /(VC)+\s*(14601.1)/,

# 'VC 14601.2',
 /(VC)+\s*(14601.2)/,

# 'VC 14601.3',
 /(VC)+\s*(14601.3)/,

# 'VC 14601.5',
 /(VC)+\s*(14601.5)/,

# 'VC 42002.1',
 /(VC)+\s*(42002.1)/,

# 'VC 2800',
 /(VC)+\s*(2800)/,

# 'VC 2801',
 /(VC)+\s*(2801)/,

# 'VC 2803',
 /(VC)+\s*(2803)/,
# 'VC 12810(a)',
 #
 /(VC)+\s*(12810)\(*a\)/,

# 'VC 12810(b)',
 /(VC)+\s*(12810)\(*b\)/,

# 'VC 12810(c)',
 /(VC)+\s*(12810)\(*c\)/,

# 'VC 12810(d)',
 /(VC)+\s*(12810)\(*d\)/,

# 'VC 12810(e)'
 /(VC)+\s*(12810)\(*e\)/
]
