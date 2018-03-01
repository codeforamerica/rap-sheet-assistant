class PC1203Classifier
  def initialize(user, count)
    @user = user
    @count = count
  end

  def potentially_eligible?
    return false unless count.event.sentence
    return false unless %w(M F).include?(count.severity)

    !count.event.sentence.had_prison?
  end

  def eligible?
    return false if @user.on_parole
    return false if @user.on_probation && !@user.finished_half_of_probation
    return false if @user.outstanding_warrant

    potentially_eligible?
  end

  def action
    # TBD

    # @user.owe_fees ? 'Discretionary' : ' Mandatory'
  end

  private

  attr_reader :count
end
