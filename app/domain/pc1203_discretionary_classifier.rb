class PC1203DiscretionaryClassifier < PC1203Classifier
  def eligible?
    super && discretionary?
  end
end
