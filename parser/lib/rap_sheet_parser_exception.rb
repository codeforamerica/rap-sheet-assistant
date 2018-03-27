class RapSheetParserException < StandardError
  def initialize(parser)
    @parser = parser
  end

  def message
    @parser.failure_reason
  end
end
