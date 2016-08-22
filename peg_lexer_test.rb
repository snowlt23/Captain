
require './peg_lexer'

lexer = Lexer.new()

parsed = lexer.parse(File.read("example.c"))
# p parsed.type
# # p parsed.value
# for e in parsed.value
#     p e
#     print "\n"
# end

s = "\n"
indent = Indent.new()
for e in parsed.value
    s += e.generate_src(indent) + "\n"
end
puts s
