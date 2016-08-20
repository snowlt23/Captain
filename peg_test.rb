
require './peg'

include PEG

parser = str("if") >> str("a").garbage >> str("b")

parsed = parser.exec("ifab")
p parsed.type
p parsed.value
