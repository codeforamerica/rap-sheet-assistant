class ConvictionEventCollection < Array
  def conviction_counts(user)
    ConvictionCountCollection.new(user, self.flat_map(&:counts))
  end
end
