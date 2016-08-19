
require './lexer'

lexer = Lexer.new(File.read("example.c"))
puts lexer.expr().to_s
puts lexer.expr().to_s
