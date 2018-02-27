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
      convicted_counts = e.counts.elements.select { |c| c.disposition.is_a? CountGrammar::Convicted }

      event = {
        date: parse_date(e),
        case_number: CaseNumberPresenter.present(e.case_number),
        courthouse: CourthousePresenter.present(e.courthouse),
        sentence: SentencePresenter.present(e.sentence)
      }

      counts = convicted_counts.map do |count|
        ConvictionCount.new(event, count)
      end

      event.merge(counts: counts)
    end
  end

  private

  def self.parse_date(e)
    Date.strptime(e.date.text_value, '%Y%m%d')
  end

  class RapSheetParseError < StandardError
    def initialize(e = nil)
      super e
      # Preserve the original exception's data if provided
      if e && e.is_a?(Exception)
        set_backtrace e.backtrace
        message.prepend "#{e.class}: "
      end
    end
  end
end
