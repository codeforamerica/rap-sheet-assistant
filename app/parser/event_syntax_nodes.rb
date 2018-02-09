require_relative './treetop_monkeypatches'

module EventGrammar
  class CourtEvent < Treetop::Runtime::SyntaxNode
    def case_number
      counts[0].case_number if counts[0].is_a? CountWithCaseNumber
    end
  end

  class Count < Treetop::Runtime::SyntaxNode
    Treetop.load 'app/parser/common_grammar'
    Treetop.load 'app/parser/count_grammar'

    def disposition
      count_content.disposition_content
    end

    def code_section
      count_content.code_section
    end

    def code_section_description
      count_content.code_section_description
    end

    def count_content
      @count_content ||= CountGrammarParser.new.parse(count_info.text_value)
    end
  end

  class CountWithCaseNumber < Count; end
end