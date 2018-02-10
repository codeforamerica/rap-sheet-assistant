require_relative './treetop_monkeypatches'

module CountGrammar
  class Count < Treetop::Runtime::SyntaxNode
    def code_section
      if charge_line.is_a? CodeSectionLine
        charge_line.code_section
      elsif charge_line.text_value.include? 'SEE COMMENT FOR CHARGE'
        comment_charge_line = extra_count_info.elements.select do |l|
          l.is_a? CommentChargeLine
        end

        comment_charge_line.first.code_section unless comment_charge_line.empty?
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

  class CommentChargeLine < Treetop::Runtime::SyntaxNode; end
end
