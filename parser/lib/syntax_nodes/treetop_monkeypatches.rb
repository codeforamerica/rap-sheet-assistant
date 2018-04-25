# Stolen from https://github.com/elastic/logstash/blob/master/logstash-core/lib/logstash/compiler/treetop_monkeypatches.rb

require 'forwardable'

class Treetop::Runtime::SyntaxNode
  extend Forwardable

  def_delegators :elements, :[], :length, :any?, :select, :flat_map, :find, :map

  # Traverse the syntax tree recursively.
  # The order should respect the order of the configuration file as it is read
  # and written by humans (and the order in which it is parsed).
  def recurse(e, depth=0, &block)
    r = block.call(e, depth)
    e.elements.each { |e| recurse(e, depth + 1, &block) } if r && e.elements
    nil
  end

  def recursive_inject(results=[], &block)
    if !elements.nil?
      elements.each do |element|
        if block.call(element)
          results << element
        else
          element.recursive_inject(results, &block)
        end
      end
    end
    return results
  end

  # When Treetop parses the configuration file
  # it will generate a tree, the generated tree will contain
  # a few `Empty` nodes to represent the actual space/tab or newline in the file.
  # Some of theses node will point to our concrete class.
  # To fetch a specific types of object we need to follow each branch
  # and ignore the empty nodes.
  def recursive_select(*klasses)
    return recursive_inject { |e| klasses.any? {|k| e.is_a?(k)} }
  end

  def recursive_inject_parent(results=[], &block)
    if !parent.nil?
      if block.call(parent)
        results << parent
      else
        parent.recursive_inject_parent(results, &block)
      end
    end
    return results
  end

  def recursive_select_parent(results=[], klass)
    return recursive_inject_parent(results) { |e| e.is_a?(klass) }
  end

  def do_parsing(parser, text)
    result = parser.parse(text)
    raise RapSheetParserException.new(parser, text) unless result

    result
  end
end
