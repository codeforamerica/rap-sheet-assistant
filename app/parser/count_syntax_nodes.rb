require_relative './treetop_monkeypatches'

module CountGrammar
  class Count < Treetop::Runtime::SyntaxNode
    def code_section
      if charge_line.is_a? CodeSectionLine
        charge_line.code_section
      end
    end

    def code_section_description
      if charge_line.is_a? CodeSectionLine
        charge_line.code_section_description
      end
    end
  end

  class Convicted < Treetop::Runtime::SyntaxNode; end

  class CodeSectionLine < Treetop::Runtime::SyntaxNode; end
end
