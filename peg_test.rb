
require './peg'

include PEG

parser = str("if") >> str("a").except >> str("b") >> match(/[0-9]/)

parsed = parser.exec("ifab5")
p parsed.type
p parsed.value
