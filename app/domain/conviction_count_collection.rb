class ConvictionCountCollection < Array
  def events
    self.map(&:event).uniq
  end

  def severity_felony
    with_severity('F')
  end

  def severity_misdemeanor
    with_severity('M')
  end

  def severity_unknown
    with_severity(nil)
  end

  def -(another)
    self.class.new(self.to_a - another.to_a)
  end

  def select(&block)
    self.class.new(self.to_a.select(&block))
  end

  private

  def with_severity(severity)
    self.select { |count| count.severity == severity }
  end
end
