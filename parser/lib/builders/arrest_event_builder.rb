class ArrestEventBuilder
  include EventBuilder

  def build
    ArrestEvent.new(date: date)
  end
end
