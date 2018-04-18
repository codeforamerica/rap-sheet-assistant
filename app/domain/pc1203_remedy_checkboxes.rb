class PC1203RemedyCheckboxes
  def initialize(remedy)
    @remedy = remedy
  end

  def fields
    return {} unless remedy

    remedy_checkbox = {
      '1203.4' => 'topmostSubform[0].Page1[0].ProbationGranted_cb[0]',
      '1203.4a' => 'topmostSubform[0].Page1[0].OffenseWSentence_cb[0]',
      '1203.41' => 'topmostSubform[0].Page2[0].OffenseWSentence_cb[1]'
    }[remedy[:code]]

    sub_checkbox =
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

    sub_checkbox = {} if sub_checkbox.nil?

    { remedy_checkbox => '1' }.merge(sub_checkbox)
  end
  
  private
  
  attr_reader :remedy
end
