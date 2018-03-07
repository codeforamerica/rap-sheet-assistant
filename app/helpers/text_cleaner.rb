class TextCleaner
  SUBSTITUTION_PATTERNS = {
    'CNT:' => [/[Ç]NT:/, /CN[ÍI]:/],
    'INFRACTION' => ['TNFRACTION'],
    'CONV STATUS:' => [/CONV STATIS./],
    '-' => ['–'],
    'RESTN' => ['RESIN'],
    'SEN' => ['SÉN']
  }.freeze

  def self.clean(text)
    text = text.upcase
    text = text.split("\n").reject { |line| line.length <= 3 }.join("\n")

    SUBSTITUTION_PATTERNS.each do |correct_value, patterns|
      patterns.each do |pattern|
        text.gsub!(pattern, correct_value)
      end
    end

    text
  end
end
