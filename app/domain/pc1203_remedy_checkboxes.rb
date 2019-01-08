class PC1203RemedyCheckboxes
  def initialize(remedy_details)
    @remedy_details = remedy_details
  end

  def fields
    return {} unless remedy_details

    remedy_checkbox.
      merge(sub_checkbox).
      merge(question_8_checkbox)
  end

  private

  def remedy_checkbox
    {
      {
        '1203.4' => 'topmostSubform[0].Page1[0].ProbationGranted_cb[0]',
        '1203.4a' => 'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]',
        '1203.41' => 'topmostSubform[0].Page2[0].OffenseWSentence_cb[1]'
      }[remedy_details[:code]] => '1'
    }
  end

  def sub_checkbox
    sub =
      if remedy_details[:code] == '1203.4'
        {
          successful_completion: { 'topmostSubform[0].Page1[0].ProbationGrantedReason[0]' => '1' },
          early_termination: { 'topmostSubform[0].Page1[0].ProbationGrantedReason[1]' => '2' },
          discretionary: { 'topmostSubform[0].Page1[0].ProbationGrantedReason[2]' => '3' }
        }[remedy_details[:scenario]]
      elsif remedy_details[:code] == '1203.4a'
        {
          successful_completion: { 'topmostSubform[0].Page1[0].ProbationNotGrantedReason[1]' => '2' },
          discretionary: { 'topmostSubform[0].Page1[0].ProbationNotGrantedReason[0]' => '1' }
        }[remedy_details[:scenario]]
      end

    sub.present? ? sub : {}
  end

  def question_8_checkbox
    {
      '1203.4' => { 'topmostSubform[0].Page2[0].DismissSection_cb[1]' => '1' },
      '1203.4a' => { 'topmostSubform[0].Page2[0].DismissSection_cb[0]' => '2' },
      '1203.41' => { 'topmostSubform[0].Page2[0].DismissSection_cb[3]' => '3' }
    }[remedy_details[:code]]
  end

  attr_reader :remedy_details
end
