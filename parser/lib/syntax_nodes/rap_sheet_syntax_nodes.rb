module RapSheetGrammar
  class Cycle < Treetop::Runtime::SyntaxNode
    def events
      parser = CycleGrammarParser.new
      parsed_cycle = parser.parse(cycle_content.text_value)
      parsed_cycle.events
    end
  end
end
