
require './peg_lexer'
require 'pp'

lexer = Lexer.new()

parsed = lexer.parse(File.read("example.c"))
# p parsed.type
# # p parsed.value
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
