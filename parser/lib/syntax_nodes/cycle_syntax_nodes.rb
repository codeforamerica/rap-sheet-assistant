module CycleGrammar
  class Cycle < Treetop::Runtime::SyntaxNode
    def events
      recursive_select(EventContent).map do |event|
        do_parsing(EventGrammarParser.new, event.text_value)
      end
    end

    private

    def do_parsing(parser, text)
      result = parser.parse(text)
      raise RapSheetParserException.new(parser) unless result

      result
    end
  end

  class EventContent < Treetop::Runtime::SyntaxNode; end
end
