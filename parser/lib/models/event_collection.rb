class EventCollection < Array
  def with_convictions
    ConvictionEventCollection.new(self.select { |e| e.is_a? ConvictionEvent })
  end

  def arrests
    self.select do |e|
      e.is_a? ArrestEvent
    end
  end

  def custody_events
    self.select do |e|
      e.is_a? CustodyEvent
    end
  end
end
