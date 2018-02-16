require_relative './treetop_monkeypatches'

module UpdateGrammar
  class Update < Treetop::Runtime::SyntaxNode; end

  class Disposition < Treetop::Runtime::SyntaxNode
    def sentence
      update_lines.elements.find do |l|
        l.is_a? UpdateGrammar::SentenceLine
      end&.sentence
    end
  end

  class SentenceModified < Treetop::Runtime::SyntaxNode; end

  class SentenceLine < Treetop::Runtime::SyntaxNode; end
end
