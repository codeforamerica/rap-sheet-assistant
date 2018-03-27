class RapSheetPresenter
  def self.present(parsed_rap_sheet)
    court_events = parsed_rap_sheet.cycles.elements.flat_map do |cycle|
      cycle.events.select do |event|
        event.class == EventGrammar::CourtEvent
      end
    end

    conviction_events = court_events
      .select(&:is_conviction?)
      .map { |e| ConvictionEventBuilder.new(e).build }

    ConvictionEventCollection.new(conviction_events)
  end
end