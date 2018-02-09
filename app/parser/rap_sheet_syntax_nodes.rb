module RapSheetGrammar
  class Cycle < Treetop::Runtime::SyntaxNode
    Treetop.load 'app/parser/common_grammar'
    Treetop.load 'app/parser/cycle_grammar'

    def events
      parser = CycleGrammarParser.new
      parsed_cycle = parser.parse(cycle_content.text_value)
      parsed_cycle.events
    end
  end
end
