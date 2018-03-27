class ArrestEvent
  def initialize(date:)
    @date = date
  end

  attr_reader :date

  def inspect
    OkayPrint.new(self).exclude_ivars(:@counts).inspect
  end
end
