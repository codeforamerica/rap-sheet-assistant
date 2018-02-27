class PC1203Classifier
  def initialize(count)
    @count = count
  end

  def potentially_eligible?
    return false unless count.event[:sentence]

    !count.event[:sentence].split(',').any? do |sentence_component|
      sentence_component.match(/prison$/)
    end
  end

  def eligible?
    false
  end

  private

  attr_reader :count
end
