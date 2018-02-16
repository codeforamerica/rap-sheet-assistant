require_relative './treetop_monkeypatches'
Treetop.load 'app/parser/event_grammar'

module CycleGrammar
  class Cycle < Treetop::Runtime::SyntaxNode
    def events
      recursive_select(EventContent).map do |event|
        parse_event(event.text_value)
      end
    end

    private

    def parse_event(text)
      tree = EventGrammarParser.new.parse(text)

      if tree.nil?
        puts '---------- FAILED TO PARSE EVENT: --------'
        p event.text_value
      end

      tree
    end
  end

  class EventContent < Treetop::Runtime::SyntaxNode; end
end
