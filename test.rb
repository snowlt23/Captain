
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

$test_names = []

lexer.add_syntax "@" do |lex|
    name = lex.ident()
    expr = lex.function()
    if name == "test"
        $test_names.push(expr.name)
    end
    AnnotateObject.new(name, expr)
end

lexer.add_syntax "generate_test" do |lex|
    lex.expect("(")
    lex.expect(")")
    lex.expect(";")
    calls = ""
    for name in $test_names
        calls += "#{name}();"
    end
    "void generated_test() { #{calls} }"
end

parsed = lexer.toplevel()
for e in parsed
    p e
end
print "\n"
puts parsed

# puts lexer.expr().to_s
# puts lexer.expr().to_s
