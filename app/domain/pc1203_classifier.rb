class PC1203Classifier
  include Classifier

  def initialize(event:, rap_sheet:)
    super(event: event, rap_sheet: rap_sheet)

    vc_sections = ""
    Constants::VC_DUI_CODE_SECTIONS.each do |cs|
      vc_sections = "#{vc_sections}|#{Regexp.escape(cs)}"
    end

    pc_sections = ""
    Constants::PC_DUI_CODE_SECTIONS.each do |cs|
      pc_sections = "#{pc_sections}|#{Regexp.escape(cs)}"
    end

    @vc_dui_matcher = /(VC)+.*(\W+((#{vc_sections[1..-1]})[\(\)\w]*)([\/\-\s]|$)+)+.*/
    @pc_dui_matcher = /(PC)+.*(\W+((#{pc_sections[1..-1]})[\(\)\w]*)([\/\-\s]|$)+)+.*/
  end

  def eligible?
    return false unless event.sentence
    return false unless event.date
    return false if event.dismissed_by_pc1203?
    return false if event.convicted_counts.all? { |c| excluded_code_section?(c) }
    # return false if rap_sheet.currently_serving_sentence?

    code = remedy_details_hash[:code]
    if code == '1203.4'
      return true if event.date < Date.today - event.sentence.total_duration
    elsif code == '1203.4a'
      return true if event.date < Date.today - 1.year
    elsif code == '1203.41'
      return true if !event.sentence.prison && event.date < Date.today - event.sentence.total_duration - 2.year
    elsif code == '1203.42'
      return true if event.date < Date.today - event.sentence.total_duration - 2.year
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

  def excluded_code_section?(count)
    Constants::CODE_SECTIONS_EXCLUDED_FOR_PC1203_DISMISSALS.include?(count.code_section)
  end

  def dui?(count)
    if !count.code_section
      return false
    end
    count.code_section.match(@vc_dui_matcher) || count.code_section.match(@pc_dui_matcher)
  end

  def pc_1170h_count?(count)
    if !count.code_section
      return false
    end
    Constants::PC_1170H_FELONIES.include?(count.code_section)
  end

  def reducible_by_17b?(count)
    !event.sentence.prison && count.severity == 'F' && Constants::WOBBLERS.include?(count.code_section)
  end

  def discretionary?
    r = remedy_details_hash
    return nil if r.empty?
    r[:code] == '1203.41' || r[:code] == '1203.42' || r[:scenario] == :discretionary
  end

  def eligible_counts
    if eligible?
      event.convicted_counts.select { |c| !excluded_code_section?(c) }
    else
      []
    end
  end

  private

  def scenario_for_code(code)
    if code == '1203.4'
      success = !event.probation_violated?(rap_sheet)
    elsif code == '1203.4a'
      convicted_dispositions = event.convicted_counts.flat_map(&:dispositions).compact
      dispos_with_sentence = convicted_dispositions.select { |dispo| dispo.sentence }
      sentence_start_date = dispos_with_sentence[-1].date
      success = event.successfully_completed_duration?(rap_sheet, sentence_start_date, 1.year)
    else
      return nil
    end
    return :discretionary if event.counts.any? { |count| dui?(count) }
    return :discretionary if probation_revoked?
    return :unknown if event.date.nil? || success.nil?
    success ? :successful_completion : :discretionary
  end

  def probation_revoked?
    event.counts.any? { |c| c.probation_revoked? }
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
          if event.counts.any? { |count| pc_1170h_count?(count) }
            if event.date < Date.new(2011, 10, 1)
              '1203.42'
            else
              '1203.41'
            end
          elsif event.convicted_counts.all? { |count| count.severity != 'F' || reducible_by_17b?(count) }
            '1203.4a'
          else
            nil
          end
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

