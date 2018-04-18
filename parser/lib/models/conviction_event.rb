class ConvictionEvent
  def initialize(date:, case_number:, courthouse:, sentence:)
    @sentence = sentence
    @courthouse = courthouse
    @case_number = case_number
    @date = date
  end

  attr_reader :date, :case_number, :courthouse, :sentence
  attr_accessor :counts

  def successfully_completed_probation?(events)
    successfully_completed_duration?(events, sentence.probation)
  end

  def successfully_completed_year?(events)
    successfully_completed_duration?(events, 1.year)
  end

  def inspect
    OkayPrint.new(self).exclude_ivars(:@counts).inspect
  end

  def severity
    severities = counts.map(&:severity)
    ['F', 'M', 'I'].each do |s|
      return s if severities.include?(s)
    end
  end

  private

  def successfully_completed_duration?(events, duration)
    return nil if date.nil?

    events_with_dates = (events.arrests + events.custody_events).reject do |e|
      e.date.nil?
    end

    events_with_dates.all? { |e| event_outside_duration(e, duration) }
  end

  def event_outside_duration(e, duration)
    e.date < date or e.date > (date + duration)
  end
end
