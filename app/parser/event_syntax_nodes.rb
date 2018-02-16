require_relative './treetop_monkeypatches'
Treetop.load 'app/parser/count_grammar'
Treetop.load 'app/parser/update_grammar'

module EventGrammar
  class CourtEvent < Treetop::Runtime::SyntaxNode
    def case_number
      counts[0].case_number if counts[0].is_a? CountWithCaseNumber
    end

    def sentence
      count = counts.elements.find do |c|
        c.disposition.sentence
      end

      return unless count

      modified = updates.elements.map(&:update_content).find do |u|
        u.elements.any? do |d|
          d.disposition_type.is_a?(UpdateGrammar::SentenceModified)
        end
      end

      if modified
        return modified.elements.find do |d|
          d.disposition_type.is_a?(UpdateGrammar::SentenceModified)
        end.update_lines.elements.find do |l|
          l.is_a? UpdateGrammar::SentenceLine
        end.sentence
      end

      count.disposition.sentence
    end
  end

  class Count < Treetop::Runtime::SyntaxNode
    def disposition
      count_content.disposition
    end

    def code_section
      count_content.code_section
    end

    def code_section_description
      count_content.code_section_description
    end

    def count_content
      @count_content ||= CountGrammarParser.new.parse(count_info.text_value + "\n")

      if @count_content.nil?
        puts '---------- FAILED TO PARSE COUNT: --------'
        p count_info.text_value
      end

      @count_content
    end
  end

  class Update < Treetop::Runtime::SyntaxNode
    def update_content
      @update_content ||= UpdateGrammarParser.new.parse(update_info.text_value + "\n")

      if @update_content.nil?
        puts '---------- FAILED TO PARSE UPDATE: --------'
        p update_info.text_value
      end

      @update_content
    end
  end

  class CountWithCaseNumber < Count;
  end
end
