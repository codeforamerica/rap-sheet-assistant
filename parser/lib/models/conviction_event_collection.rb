class ConvictionEventCollection < Array
  def conviction_counts
    ConvictionCountCollection.new(self.flat_map(&:counts))
  end
end
