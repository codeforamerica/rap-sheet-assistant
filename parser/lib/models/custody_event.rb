class CustodyEvent
  def initialize(date:)
    @date = date
  end

  attr_reader :date

  def inspect
    OkayPrint.new(self).inspect
  end
end
