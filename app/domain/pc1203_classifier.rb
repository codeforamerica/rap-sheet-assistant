class PC1203Classifier
  include Classifier

  def initialize(event:, rap_sheet:)
    super(event: event, rap_sheet: rap_sheet)

    vc_sections = ""
    VC_DUI_CODE_SECTIONS.each do |cs|
      vc_sections = "#{vc_sections}|#{Regexp.escape(cs)}"
    end

    pc_sections = ""
    PC_DUI_CODE_SECTIONS.each do |cs|
      pc_sections = "#{pc_sections}|#{Regexp.escape(cs)}"
    end

    @vc_dui_matcher = /(VC)+.*(\W+(#{vc_sections[1..-1]})(\W|$)+)+.*/
    @pc_dui_matcher = /(PC)+.*(\W+(#{pc_sections[1..-1]})(\W|$)+)+.*/
  end

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
    count.code_section.match(@vc_dui_matcher) || count.code_section.match(@pc_dui_matcher)
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

PC_DUI_CODE_SECTIONS = [
  '191.5',
  '192(c)'
]

VC_DUI_CODE_SECTIONS = [
  '12810(a)',
  '12810(b)',
  '12810(c)',
  '12810(d)',
  '12810(e)',
  '14601',
  '14601.1',
  '14601.2',
  '14601.3',
  '14601.5',
  '20001',
  '20002',
  '21651(b)',
  '22348(b)',
  '23109(a)',
  '23109(c)',
  '23140(a)',
  '23140(b)',
  '23152',
  '23153',
  '2800',
  '2800.2',
  '2800.3',
  '2801',
  '2803',
  '31602',
  '42002.1'
]

