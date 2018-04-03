class EventCollection < Array
  def with_convictions
    filtered(ConvictionEvent)
  end

  def arrests
    filtered(ArrestEvent)
  end

  def custody_events
    filtered(CustodyEvent)
  end

  private

  def filtered(klass)
    self.class.new(self.select { |e| e.is_a? klass })
  end
end
