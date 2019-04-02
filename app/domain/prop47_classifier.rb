class Prop47Classifier
  include Classifier

  def eligible?
    !eligible_counts.empty?
  end

  def eligible_counts
    return [] if rap_sheet.superstrikes.present? || rap_sheet.sex_offender_registration?
    event.convicted_counts.select do |c|
      c.severity == 'F' && PROP47_CODE_SECTIONS.include?(c.code_section)
    end
  end

  def remedy_details
    return nil unless eligible?

    { scenario: scenario }
  end

  private

  def scenario
    return :unknown if (event.date.nil? or event.sentence.nil?)

    end_of_sentence = event.date + event.sentence.total_duration

    if end_of_sentence > Date.today
      :resentencing
    else
      :redesignation
    end
  end

  PROP47_CODE_SECTIONS = [
    'PC 459',
    'PC 470',
    'PC 471',
    'PC 472',
    'PC 475',
    'PC 476',
    'PC 484',
    'PC 484i(b)',
    'PC 484e(a)(b)(d)',
    'PC 484g',
    'PC 484h',
    'PC 487',
    'PC 487(a)',
    'PC 487(b)',
    'PC 487(c)',
    'PC 487b',
    'PC 487d',
    'PC 487e',
    'PC 487h',
    'PC 487i',
    'PC 487j',
    'PC 489',
    'PC 496(a)',
    'PC 10851',
    'PC 530.5',
    'HS 11350',
    'HS 11377',
    'HS 11357(a)',
    'PC 666'
  ].freeze
end
