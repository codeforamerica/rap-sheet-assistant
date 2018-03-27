require 'treetop'

require 'models/conviction_count'
require 'models/conviction_event'
require 'models/conviction_event_collection'
require 'models/conviction_sentence'
require 'models/okay_print'

require 'builders/case_number_builder'
require 'builders/conviction_count_builder'
require 'builders/conviction_event_builder'
require 'builders/courthouse_presenter'
require 'builders/rap_sheet_presenter'

require 'syntax_nodes/treetop_monkeypatches'
require 'syntax_nodes/cycle_syntax_nodes'
require 'syntax_nodes/rap_sheet_syntax_nodes'
require 'syntax_nodes/event_syntax_nodes'
require 'syntax_nodes/count_syntax_nodes'
require 'syntax_nodes/update_syntax_nodes'

require 'text_cleaner'
require 'rap_sheet_parser_exception'

Treetop.load 'parser/lib/grammars/common_grammar'
Treetop.load 'parser/lib/grammars/update_grammar'
Treetop.load 'parser/lib/grammars/cycle_grammar'
Treetop.load 'parser/lib/grammars/count_grammar'
Treetop.load 'parser/lib/grammars/event_grammar'
Treetop.load 'parser/lib/grammars/rap_sheet_grammar'

class Parser
  def parse(text)
    cleaned_text = TextCleaner.clean(text)
    do_parsing(RapSheetGrammarParser.new, cleaned_text)
  end

  def do_parsing(parser, text)
    result = parser.parse(text)
    raise RapSheetParserException.new(parser) unless result

    result
  end
end
