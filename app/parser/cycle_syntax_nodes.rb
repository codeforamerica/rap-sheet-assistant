require_relative './treetop_monkeypatches'

module CycleGrammar
  class Cycle < Treetop::Runtime::SyntaxNode
    Treetop.load 'app/parser/event_grammar'

    def events
      parser = EventGrammarParser.new

      recursive_select(EventContent).map do |event|
        parser.parse(event.text_value)
      end
    end
  end

  class EventContent < Treetop::Runtime::SyntaxNode; end
end
