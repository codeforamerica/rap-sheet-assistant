module SentenceGrammar
  class Probation < Treetop::Runtime::SyntaxNode; end
  class Jail < Treetop::Runtime::SyntaxNode; end
  class Prison < Treetop::Runtime::SyntaxNode; end
  class Detail < Treetop::Runtime::SyntaxNode; end

  class Sentence < Treetop::Runtime::SyntaxNode
    def probation
      content_class(Probation).first
    end

    def jail
      content_class(Jail).first
    end

    def prison
      content_class(Prison).first
    end

    def details
      content_class(Detail)
    end
    
    private

    def content_class(klass)
      map(&:sentence_content).
        select { |c| c.is_a? klass }
    end
  end
end
