require_relative './rap_sheet_syntax_nodes'
require_relative './cycle_syntax_nodes'
require_relative './event_syntax_nodes'

class Parser
  Treetop.load 'app/parser/rap_sheet_grammar'

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
