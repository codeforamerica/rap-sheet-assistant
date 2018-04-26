class Prop64Classifier
  include Classifier

  def eligible?
    !eligible_counts.empty?
  end

  def potentially_eligible?
    eligible?
  end

  def eligible_counts
    event.counts.select do |c|
      c.code_section && dismissible_codes.any? do |d|
        c.code_section.starts_with? d
      end
    end
  end

  def remedy
    {
      codes: eligible_counts.map do |c|
        dismissible_codes.find do |d|
          c.code_section.starts_with? d
        end
      end,
      scenario: scenario
    }
  end

  def potentially_eligible_counts
    eligible_counts
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

  def dismissible_codes
    [
      'HS 11357',
      'HS 11358',
      'HS 11359',
      'HS 11360',
      'HS 11362.1'
    ]
  end
end
