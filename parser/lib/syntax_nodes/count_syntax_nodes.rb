module CountGrammar
  class Count < Treetop::Runtime::SyntaxNode
    def code_section
      if charge_line.is_a? CodeSectionLine
        charge_line.code_section
      elsif charge_line.text_value.include? 'SEE COMMENT FOR CHARGE'
        if disposition.is_a? Convicted
          comment_charge_line = disposition.extra_conviction_info.select do |l|
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
  end

  class Disposition < Treetop::Runtime::SyntaxNode
    def sentence
      nil
    end
  end

  class Convicted < Disposition
    def severity
      extra_conviction_info.find { |l| l.is_a? SeverityLine }&.severity
    end

    def sentence
      @sentence ||= begin
        if sentence_line
          sentence_text = TextCleaner.clean_sentence(sentence_line.sentence.text_value)
          do_parsing(SentenceGrammarParser.new, sentence_text)
        end
      end
    end

    private
    
    def sentence_line
      extra_conviction_info.find { |l| l.is_a? SentenceLine }
    end
  end

  class CodeSectionLine < Treetop::Runtime::SyntaxNode; end

  class SeverityLine < Treetop::Runtime::SyntaxNode; end

  class CommentChargeLine < Treetop::Runtime::SyntaxNode; end

  class SentenceLine < Treetop::Runtime::SyntaxNode; end
end
