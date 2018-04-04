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
    return nil if date.nil?

    events_with_dates = (events.arrests + events.custody_events).reject do |e|
      e.date.nil?
    end

    events_with_dates.all? { |e| event_outside_probation_period(e) }
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

  def event_outside_probation_period(e)
    e.date < date or e.date > (date + sentence.probation)
  end
end
