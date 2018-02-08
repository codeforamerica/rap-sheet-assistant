require_relative './treetop_monkeypatches'

module EventGrammar
  class CourtEvent < Treetop::Runtime::SyntaxNode
    def case_number
      counts[0].case_number if counts[0].is_a? CountWithCaseNumber
    end
  end

  class Count < Treetop::Runtime::SyntaxNode
    def disposition
      count_content.disposition_content
    end

    def penal_code
      count_content.charge_line.penal_code
    end

    def penal_code_description
      count_content.charge_line.penal_code_description
    end
  end

  class Convicted < Treetop::Runtime::SyntaxNode; end

  class CountWithCaseNumber < Count; end
end
