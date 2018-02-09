require_relative './treetop_monkeypatches'

module CountGrammar
  class Count < Treetop::Runtime::SyntaxNode
    def penal_code
      if charge_line.is_a? PenalCodeLine
        charge_line.penal_code
      end
    end

    def penal_code_description
      if charge_line.is_a? PenalCodeLine
        charge_line.penal_code_description
      end
    end
  end

  class Convicted < Treetop::Runtime::SyntaxNode; end

  class PenalCodeLine < Treetop::Runtime::SyntaxNode; end
end
