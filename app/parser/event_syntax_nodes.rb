require_relative './treetop_monkeypatches'

module EventGrammar
  class CourtEvent < Treetop::Runtime::SyntaxNode
    def case_number
      counts[0].case_number
    end
  end

  class Count < Treetop::Runtime::SyntaxNode
    def disposition
      count_content.disposition_content
    end
  end
end
