class RapSheetPresenter
  def self.present(parsed_rap_sheet)
    court_events = parsed_rap_sheet.cycles.elements.flat_map do |cycle|
      cycle.events.select do |event|
        event.class == EventGrammar::CourtEvent
      end
    end

    court_events = court_events.select do |e|
      e.counts.elements.any? { |c| c.disposition.is_a? CountGrammar::Convicted }
    end

    convictions = court_events.map do |e|
      convicted_counts = e.counts.elements.select { |c| c.disposition.is_a? CountGrammar::Convicted }

      event = {
        date: parse_date(e),
        case_number: CaseNumberPresenter.present(e.case_number),
        courthouse: CourthousePresenter.present(e.courthouse),
        sentence: SentencePresenter.present(e.sentence)
      }

      counts = convicted_counts.map do |count|
        Count.new(event, count)
      end

      event.merge(counts: counts)
    end

    {
      events_with_convictions: convictions,
      conviction_counts: convictions.flat_map { |c| c[:counts] }
    }
  end

  private

  def self.parse_date(e)
    Date.strptime(e.date.text_value, '%Y%m%d')
  end
end
