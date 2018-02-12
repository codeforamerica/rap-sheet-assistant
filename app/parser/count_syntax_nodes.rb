require_relative './treetop_monkeypatches'

module CountGrammar
  class Count < Treetop::Runtime::SyntaxNode
    def code_section
      if charge_line.is_a? CodeSectionLine
        charge_line.code_section
      elsif charge_line.text_value.include? 'SEE COMMENT FOR CHARGE'
        if disposition_content.is_a? Convicted
          comment_charge_line = disposition_content.extra_conviction_info.elements.select do |l|
            l.is_a? CommentChargeLine
          end

          comment_charge_line.first.code_section unless comment_charge_line.empty?
        end
      end
    end

    def code_section_description
      if charge_line.is_a? CodeSectionLine
        charge_line.code_section_description
      end
    end

    def conviction
      disposition_content if disposition_content.is_a? Convicted
    end
  end

  class Convicted < Treetop::Runtime::SyntaxNode
    def severity
      severity_line = extra_conviction_info.elements.select do |l|
        l.is_a? SeverityLine
      end
      if severity_line.empty?
        puts extra_conviction_info.text_value
      else
        severity_line.first.severity
      end
    end
  end

  class CodeSectionLine < Treetop::Runtime::SyntaxNode;
  end

  class SeverityLine < Treetop::Runtime::SyntaxNode;
  end

  class CommentChargeLine < Treetop::Runtime::SyntaxNode;
  end
end
