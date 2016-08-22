
require './peg_lexer'
require 'pp'

lexer = Lexer.new()

# string_parsed = lexer.string.parse("\"test\"", 0)
# puts string_parsed.type
# puts string_parsed.pos
# p string_parsed.value

parsed = lexer.parse(File.read("example.c"))
for e in parsed.value
    pp e
    print "\n"
end

s = "\n"
indent = Indent.new()
for e in parsed.value
    s += e.generate_src(indent) + "\n\n"
end
puts s
