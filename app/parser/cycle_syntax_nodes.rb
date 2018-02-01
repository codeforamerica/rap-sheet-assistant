require_relative './treetop_monkeypatches'

module CycleGrammar
  class Cycle < Treetop::Runtime::SyntaxNode
    def events
      recursive_select(EventContent)
    end
  end

  class EventContent < Treetop::Runtime::SyntaxNode; end
end
