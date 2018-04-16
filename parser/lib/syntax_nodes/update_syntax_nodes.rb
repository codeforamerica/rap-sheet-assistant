require_relative './treetop_monkeypatches'

module UpdateGrammar
  class Update < Treetop::Runtime::SyntaxNode; end

  class Disposition < Treetop::Runtime::SyntaxNode
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
      update_lines.find { |l| l.is_a? UpdateGrammar::SentenceLine }
    end
  end

  class SentenceModified < Treetop::Runtime::SyntaxNode; end

  class SentenceLine < Treetop::Runtime::SyntaxNode; end
end
