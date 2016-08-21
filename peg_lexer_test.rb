
require './peg_lexer'

indent = Indent.new()
puts(indent.block do
    add "if (true) {"
    indent.block do
        add "printf(\"Hello!!\\n\");"
    end
    add "}"
end)

puts(indent.block do
    add "while (false) {"
    indent.block do
        add "printf(\"Hello!!\\n\");"
    end
    add "}"
end)

lexer = Lexer.new()
parsed = lexer.ident.exec("abcd01")
puts parsed.type
puts parsed.value

s_parsed = lexer.string.exec("L\"Hello!!\"")
puts s_parsed.type
puts s_parsed.value
