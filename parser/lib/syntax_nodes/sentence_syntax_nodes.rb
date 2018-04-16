module SentenceGrammar
  class Probation < Treetop::Runtime::SyntaxNode; end
  class Jail < Treetop::Runtime::SyntaxNode; end
  class Detail < Treetop::Runtime::SyntaxNode; end

  class Sentence < Treetop::Runtime::SyntaxNode
    def probation
      recursive_select(Probation).first
    end

    def jail
      recursive_select(Jail).first
    end

    def details
      recursive_select(Detail)
    end
  end
end
