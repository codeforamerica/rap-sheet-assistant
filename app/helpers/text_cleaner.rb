class TextCleaner
  SUBSTITUTION_PATTERNS = {
    'CNT:' => [/[cÇ]NT:/, /CN[tÍI]:/],
    '-' => ['–']
  }.freeze

  def self.clean(text)
    SUBSTITUTION_PATTERNS.each do |correct_value, patterns|
      patterns.each do |pattern|
        text.gsub!(pattern, correct_value)
      end
    end

    text
  end
end
