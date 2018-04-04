class EventCollectionBuilder
  def self.build(parsed_rap_sheet)
    event_nodes = parsed_rap_sheet.cycles.flat_map do |cycle|
      cycle.events.select do |event|
        event.is_a? EventGrammar::Event
      end
    end

    events = event_nodes.map do |e|
      if conviction_event(e)
        ConvictionEventBuilder.new(e).build
      elsif e.is_a? EventGrammar::ArrestEvent
        ArrestEventBuilder.new(e).build
      elsif e.is_a? EventGrammar::CustodyEvent
        CustodyEventBuilder.new(e).build
      end
    end.compact

    EventCollection.new(events)
  end

  private

  def self.conviction_event(e)
    e.is_a? EventGrammar::CourtEvent and e.is_conviction?
  end
end
