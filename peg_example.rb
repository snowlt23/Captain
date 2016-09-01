
require './peg_lexer'
require 'pp'

lexer = Lexer.new()

# string_parsed = lexer.string.parse("\"test\"", 0)
# puts string_parsed.type
# puts string_parsed.pos
# p string_parsed.value

parsed = lexer.parse(File.read("peg_example.c"))
for e in parsed.value
    pp e
    print "\n"
end

# puts top_generate_src(parsed, compress: false)
