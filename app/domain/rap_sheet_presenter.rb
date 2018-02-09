class RapSheetPresenter
  def initialize(parsed_rap_sheet)
    @parsed_rap_sheet = parsed_rap_sheet
  end

  def convictions
    court_events = parsed_rap_sheet.cycles.elements.flat_map do |cycle|
      cycle.events.select do |event|
        event.class == EventGrammar::CourtEvent
      end
    end

    court_events = court_events.select do |e|
      e.counts.elements.any? { |c| c.disposition.is_a? EventGrammar::Convicted }
    end

    court_events.map do |e|
      convicted_counts = e.counts.elements.select {|c| c.disposition.is_a? EventGrammar::Convicted}

      {
        counts: convicted_counts.map {|c| CountPresenter.present(c)},
        date: format_date(e),
        case_number: CaseNumberPresenter.present(e.case_number),
        courthouse: CourthousePresenter.present(e.courthouse),
      }
    end
  end

  private

  attr_reader :parsed_rap_sheet

  def format_date(e)
    Date.strptime(e.date.text_value, '%Y%m%d')
  end
end
