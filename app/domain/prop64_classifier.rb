class Prop64Classifier
  include Classifier

  def eligible?
    !eligible_counts.empty?
  end

  def eligible_counts
    return [] if event.date && event.date > Date.new(2016, 11, 8)

    event.convicted_counts.select do |c|
      c.subsection_of_any?(dismissible_codes)
    end
  end

  def remedy_details
    {
      codes: eligible_counts.map do |c|
        dismissible_codes.find do |d|
          c.subsection_of?(d)
        end
      end,
      scenario: scenario
    }
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
