
require './peg'

include PEG

parser = str("if") >> str("a").except >> str("b")

parsed = parser.exec("ifcb")
p parsed.type
p parsed.value
