class PC1203MandatoryClassifier < PC1203Classifier
  def eligible?
    super && !discretionary?
  end
end
