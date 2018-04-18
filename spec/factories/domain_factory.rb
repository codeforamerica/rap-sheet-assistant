def build_conviction_count(event: nil, code_section_description: nil, code: nil, section: nil, severity: nil)
  ConvictionCount.new(
    event: event,
    code_section_description: code_section_description,
    severity: severity,
    code: code,
    section: section
  )
end
