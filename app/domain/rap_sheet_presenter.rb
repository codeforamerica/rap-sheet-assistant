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
      {
        date: format_date(e),
        case_number: format_case_number(e.case_number),
        courthouse: format_courthouse(e),
      }
    end
  end

  private

  attr_reader :parsed_rap_sheet

  def format_courthouse(e)
    courthouse_names = {
      'CASC SAN FRANCISCO' => 'CASC San Francisco',
      'CAMC RICHMOND' => 'CAMC Richmond',
      'CASC MCRICHMOND' => 'CASC Richmond',
      'CAMC CONCORD' => 'CAMC Concord',
      'CASC CONCORD' => 'CASC Concord',
      'CASC CONTRA COSTA' => 'CASC Contra Costa',
      'CASC PITTSBURG' => 'CASC Pittsburg',
      'CASC PLACER' => 'CASC Placer',
      'CASC WALNUT CREEK' => 'CASC Walnut Creek',
      'CASC MCSAN RAFAEL' => 'CASC MC San Rafael',
      'CASC MCOAKLAND' => 'CASC MC Oakland',
      'CAMC HAYWARD' => 'CAMC Hayward',
      'CASC MCSACRAMENTO' => 'CASC MC Sacramento',
      'CASC SN JOSE' => 'CASC San Jose',
      'CAMC LOS ANGELES METRO' => 'CAMC Los Angeles Metro'
    }

    courthouse_text = e.courthouse.text_value.gsub('.', '').upcase

    if courthouse_names.key?(courthouse_text)
      courthouse_names[courthouse_text]
    else
      courthouse_text
    end
  end

  def format_case_number(c)
    return if c.nil?
    stripped_case_number = c.text_value.delete(' ').delete('.')[1..-1]
    strip_trailing_punctuation(stripped_case_number)
  end

  def format_date(e)
    Date.strptime(e.date.text_value, '%Y%m%d')
  end

  def strip_trailing_punctuation(str)
    new_str = str

    while new_str.end_with?('.', ':')
      new_str = new_str[0..-2]
    end
    new_str
  end
end
