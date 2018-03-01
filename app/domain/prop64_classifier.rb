class Prop64Classifier
  def initialize(user, count)
    @user = user
    @count = count
  end

  def potentially_eligible?
    dismissible_codes.include?(count.code_section)
  end

  def eligible?
    potentially_eligible?
  end

  def action
    end_of_sentence = count.event.date + count.event.sentence.total_duration

    if end_of_sentence > Date.today
      'Resentencing'
    else
      'Redesignation'
    end
  end

  private

  attr_reader :count

  def dismissible_codes
    [
      'HS 11357',
      'HS 11358',
      'HS 11359',
      'HS 11360',
      'HS 11362.1'
    ]
  end
end
