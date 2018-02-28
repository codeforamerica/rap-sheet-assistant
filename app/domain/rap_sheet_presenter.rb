class RapSheetPresenter
  def self.present(parsed_rap_sheet)
    court_events = parsed_rap_sheet.cycles.elements.flat_map do |cycle|
      cycle.events.select do |event|
        event.class == EventGrammar::CourtEvent
      end
    end

    court_events.select do |e|
      e.counts.elements.any? { |c| c.disposition.is_a? CountGrammar::Convicted }
    end.map do |e|
      convicted_counts = e.counts.elements.select do |c|
        c.disposition.is_a? CountGrammar::Convicted
      end

      ConvictionEvent.new(e, convicted_counts)
    end
  end
end
