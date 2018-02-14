Treetop.load 'app/parser/rap_sheet_grammar'

def maybe_require_dependency(thing)
  if respond_to?(:require_dependency)
    require_dependency thing
  else
    require_relative thing
  end
end

maybe_require_dependency './rap_sheet_syntax_nodes'
maybe_require_dependency './cycle_syntax_nodes'
maybe_require_dependency './event_syntax_nodes'
maybe_require_dependency './count_syntax_nodes'

class Parser
  def parse(text)
    cleaned_text = TextCleaner.clean(text)
    do_parsing(RapSheetGrammarParser.new, cleaned_text)
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
