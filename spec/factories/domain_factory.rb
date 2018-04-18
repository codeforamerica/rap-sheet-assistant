def build_conviction_event(date: nil, case_number: nil, courthouse: nil, sentence: nil, counts: nil)
  event = ConvictionEvent.new(
    date: date,
    case_number: case_number,
    courthouse: courthouse,
    sentence: sentence
  )
  event.counts = counts
  event
end

def build_conviction_count(event: nil, code_section_description: nil, code: nil, section: nil, severity: nil)
  ConvictionCount.new(
    event: event,
    code_section_description: code_section_description,
    severity: severity,
    code: code,
    section: section
  )
end
