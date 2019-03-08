class TranscriptPresenter
  def initialize(rap_sheet)
    @rap_sheet = rap_sheet
  end

  def rows
    result = []
    @rap_sheet.parsed.convictions.each do |conviction|
      conviction.counts.each_with_index do |count, i|
        row = {}
        row[:first_row_in_case?] = (i == 0)
        row[:date] = conviction.date || '—'
        row[:courthouse] = conviction.courthouse || '—'
        row[:case_number] = conviction.case_number ? "##{conviction.case_number}" : '—'
        row[:severity] = count.disposition&.severity
        row[:code_section] = count.code_section || '—'

        sentence = count.disposition&.sentence
        row[:probation] = format_duration(sentence&.probation)
        row[:prison] = format_duration(sentence&.prison)

        result.append(row)
      end
    end
    return result
  end

  private

  def format_duration(duration)
    if duration
      "#{duration.parts.values[0]} #{duration.parts.keys[0]}"
    else
      '—'
    end
  end
end
