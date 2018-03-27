class EventCollection < Array
  def with_convictions
    conviction_events = self.select do |e|
      e.is_a? ConvictionEvent
    end
    ConvictionEventCollection.new(conviction_events)
  end
end
