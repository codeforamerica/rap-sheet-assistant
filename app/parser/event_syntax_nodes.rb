require_relative './treetop_monkeypatches'
Treetop.load 'app/parser/count_grammar'

module EventGrammar
  class CourtEvent < Treetop::Runtime::SyntaxNode
    def case_number
      counts[0].case_number if counts[0].is_a? CountWithCaseNumber
    end
  end

  class Count < Treetop::Runtime::SyntaxNode
    def disposition
      count_content.disposition
    end

    def code_section
      count_content.code_section
    end

    def code_section_description
      count_content.code_section_description
    end

    def count_content
      @count_content ||= CountGrammarParser.new.parse(count_info.text_value + "\n")

      if @count_content.nil?
        puts '---------- FAILED TO PARSE COUNT: --------'
        p count_info.text_value
      end

      @count_content
    end
  end

  class CountWithCaseNumber < Count; end
end
