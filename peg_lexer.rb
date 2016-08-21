
require './peg'
include PEG

class Indent
    def initialize(indent: "    ", compress: false)
        @num = 0
        @indent = indent
        @compress = compress
        @current = ""
    end
    def gen
        s = ""
        for i in 1..@num
            s += @indent
        end
        s
    end
    def add(s)
        if @compress
            @current += s
        else
            @current += self.gen() + s + "\n"
        end
    end
    def block(&f)
        @num += 1
        self.instance_eval(&f)
        @num -= 1
        s = @current
        if @num == 0
            @current = ""
        end
        s
    end
end

class Lexer
    def space
        (str("\s") / str("\t") / str("\n")).repeat1
    end
    def sp
        space.opt
    end
    def ident
        sp >> (match('[a-zA-Z]') >> match('[a-zA-Z0-9]').repeat).concat
    end
end
