class TranscriptPresenter
  def initialize(rap_sheet)
    @rap_sheet = rap_sheet.parsed
    @eligibility = EligibilityChecker.new(@rap_sheet)
  end

  def rows
    result = []
    @rap_sheet.convictions.each do |conviction|
      conviction.convicted_counts.each_with_index do |count, i|
        row = {}
        row[:first_row_in_case?] = (i == 0)
        row[:date] = conviction.date || '—'
        row[:courthouse] = conviction.courthouse || '—'
        row[:case_number] = conviction.case_number ? "##{conviction.case_number}" : '—'
        row[:severity] = count.severity
        row[:code_section] = count.code_section || '—'
        if count.flags.include?('-ATTEMPTED')
          row[:code_section] += '-ATTEMPTED'
        end

        sentence = count.sentence
        if count.sentence.nil?
          sentence = conviction.sentence
        end
        row[:probation] = format_duration(sentence&.probation)
        row[:prison] = format_duration(sentence&.prison)

        count_eligibility = @eligibility.eligiblity_for_count(conviction, count)

        remedy_string = count_eligibility.map do |info|
          if info[:remedy] == :prop64
            'p64'
          elsif info[:remedy] == :prop47
            'p47'
          elsif info[:remedy] == :pc1203_mandatory
            "#{info[:remedy_details][:code]} mand"
          elsif info[:remedy] == :pc1203_discretionary
            "#{info[:remedy_details][:code]} disc"
          end
        end.join(', ')

        if count_eligibility.empty?
          remedy_string = 'x'
        end

        row[:remedy] = remedy_string

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
      '-'
    end
  end
end
