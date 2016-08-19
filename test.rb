
require './lexer'

lexer = Lexer.new(File.read("example.c"))
# puts lexer.expr().to_s
# puts lexer.expr().to_s

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

class AnnotateObject
    def initialize(name, expr)
        @name = name
        @expr = expr
    end
    def to_s()
        return @expr.to_s
    end
end

lexer.add_syntax "@" do |lex|
    name = lex.ident()
    expr = lex.function()
    AnnotateObject.new(name, expr)
end

parsed = lexer.toplevel()
print parsed
print "\n\n"
puts parsed

# puts lexer.expr().to_s
# puts lexer.expr().to_s
