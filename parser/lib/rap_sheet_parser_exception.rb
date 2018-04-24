class RapSheetParserException < StandardError
  def initialize(parser, text)
    @parser = parser
    @text = text
  end

  def message
    "#{@parser.class} #{@parser.failure_reason}\n#{@text}"
  end
end
