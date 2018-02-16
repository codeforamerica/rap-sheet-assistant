require_relative './treetop_monkeypatches'

module UpdateGrammar
  class Update < Treetop::Runtime::SyntaxNode
  end

  class SentenceModified < Treetop::Runtime::SyntaxNode; end
  class SentenceLine < Treetop::Runtime::SyntaxNode; end
end
