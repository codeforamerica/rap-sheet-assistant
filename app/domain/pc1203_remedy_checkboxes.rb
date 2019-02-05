class PC1203RemedyCheckboxes
  def initialize(remedy_details)
    @remedy_details = remedy_details
  end

  def fields
    result = {}
    return result unless remedy_details

    result[remedy_checkbox] = 'Yes'
    result[sub_checkbox] = 'Yes' if sub_checkbox
    result
  end

  private

  def remedy_checkbox
    {
      '1203.4' => 'Field43',
      '1203.4a' => 'Field51',
      '1203.41' => 'Field57'
    }[remedy_details[:code]]
  end

  def sub_checkbox
    if remedy_details[:code] == '1203.4'
      {
        successful_completion: 'Field44',
        early_termination: 'Field45',
        discretionary: 'Field46'
      }[remedy_details[:scenario]]
    elsif remedy_details[:code] == '1203.4a'
      {
        successful_completion: 'Field52',
        discretionary: 'Field53'
      }[remedy_details[:scenario]]
    end
  end

  attr_reader :remedy_details
end
