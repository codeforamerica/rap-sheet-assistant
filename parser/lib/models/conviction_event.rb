class ConvictionEvent
  def initialize(date:, case_number:, courthouse:, sentence:)
    @sentence = sentence
    @courthouse = courthouse
    @case_number = case_number
    @date = date
  end

  attr_reader :date, :case_number, :courthouse, :sentence
  attr_accessor :counts

  def inspect
    OkayPrint.new(self).exclude_ivars(:@counts).inspect
  end

  def severity
    severities = counts.map(&:severity)
    ['F', 'M', 'I'].each do |s|
      return s if severities.include?(s)
    end
  end
end
