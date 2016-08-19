
require './lexer'

lexer = Lexer.new(File.read("example.c"))
puts lexer.expr().to_s
puts lexer.expr().to_s

class ClassObject
    def initialize(name)
        @name = name
    end
    def to_s()
        return "class #{@name}"
    end
end

lexer.add_syntax :class do |lex|
    name = lex.ident()
    ClassObject.new(name)
end

puts lexer.expr().to_s
puts lexer.expr().to_s
