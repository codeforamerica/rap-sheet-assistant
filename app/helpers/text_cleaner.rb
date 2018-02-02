class TextCleaner
  def self.clean(text)
    text.gsub('–','-')
  end
end
