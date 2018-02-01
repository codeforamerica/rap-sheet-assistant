class Parser
  Treetop.load 'grammar/rap_sheet_grammar'

  def parse(text)
    do_parsing(RapSheetGrammarParser.new, text)
  end

  def do_parsing(parser, text)
    result = parser.parse(text)
    unless result
      puts parser.failure_reason
      puts parser.failure_line
      puts parser.failure_column
    end
    result
  end
end
