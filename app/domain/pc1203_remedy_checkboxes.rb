class PC1203RemedyCheckboxes
  def initialize(remedy)
    @remedy = remedy
  end

  def fields
    return {} unless remedy

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
      }[remedy[:code]] => '1'
    }
  end

  def sub_checkbox
    sub =
      if remedy[:code] == '1203.4'
        {
          successful_completion: { 'topmostSubform[0].Page1[0].ProbationGrantedReason[0]' => '1' },
          early_termination: { 'topmostSubform[0].Page1[0].ProbationGrantedReason[1]' => '2' },
          discretionary: { 'topmostSubform[0].Page1[0].ProbationGrantedReason[2]' => '3' }
        }[remedy[:scenario]]
      elsif remedy[:code] == '1203.4a'
        {
          successful_completion: { 'topmostSubform[0].Page1[0].ProbationNotGrantedReason[1]' => '2' },
          discretionary: { 'topmostSubform[0].Page1[0].ProbationNotGrantedReason[0]' => '1' }
        }[remedy[:scenario]]
      end

    sub.present? ? sub : {}
  end

  def question_8_checkbox
    {
      '1203.4' => { 'topmostSubform[0].Page2[0].DismissSection_cb[1]' => '1' },
      '1203.4a' => { 'topmostSubform[0].Page2[0].DismissSection_cb[0]' => '2' },
      '1203.41' => { 'topmostSubform[0].Page2[0].DismissSection_cb[3]' => '3' }
    }[remedy[:code]]
  end

  attr_reader :remedy
end
