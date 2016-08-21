
require './peg'
include PEG

def args_to_src(indent, args)
    args.map{|e| e.generate_src(indent)}.join(",")
end

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

class CString
    attr_accessor :prefix, :s
    def initialize(prefix, s)
        @prefix = prefix
        @s = s
    end
    def generate_src(indent)
        "#{@prefix}\"#{@s}\""
    end
end

class CCharacter
    attr_accessor :c
    def initialize(c)
        @c = c
    end
    def generate_src(indent)
        "'#{@c}'"
    end
end

class COperator
    attr_accessor :op
    def initialize(op)
        @op = op
    end
    def generate_src(indent)
        "#{@op}"
    end
end

class CFCall
    attr_accessor :name, :args
    def initialize(name, args)
        @name = name
        @args = args
    end
    def generate_src(indent)
        "#{@name}(#{args_to_src(@args)})"
    end
end

class Lexer
    def space
        (str("\s") / str("\t") / str("\n")).repeat1
    end
    def sp
        space.opt.garbage
    end
    def expect(s) # primitive
        (sp >> str(s)).garbage
    end
    def ident # primitive
        sp >> (match('[a-zA-Z]') >> match('[a-zA-Z0-9]').repeat).concat
    end
    def integer # primitive
        sp >> match('[0-9]').repeat1.map do |parsed|
            Integer(parsed)
        end
    end
    def float # primitive
        (sp >> match('[0-9]').repeat1 >> str(".") >> match('[0-9]').repeat1).map do |parsed|
            Float(parsed[0] + parsed[1] + parsed[2])
        end
    end
    def number
        integer / float
    end
    def string_inside
        Parser.new do |input, pos|
            s = ""
            escape_flag = false
            while true
                c = input[pos]
                if c == "\"" && escape_flag
                    s += "\""
                elsif c == "\""
                    pos += 1
                    break
                elsif c == "\\"
                    escape_flag = true
                else
                    s += c
                    escape_flag = false
                end
                pos += 1
            end
            Result.success(s, pos)
        end
    end
    def string # primitive
        (sp >> ident.opt >> str("\"").garbage >> string_inside).map do |parsed|
            CString.new(parsed[0], parsed[1])
        end
    end
    def character # primitive
        (sp >> str("'").garbage >> match('.') >> str("'").garbage).map do |parsed|
            CCharacter.new(parsed[0])
        end
    end
    def operator # primitive
        sp >> Parser.new do |input, pos|
            opdata = nil
            for op in $operators
                if input[pos, op.length] == op
                    opdata = op
                    pos += op.length
                    break
                end
            end
            if opdata != nil
                Result.success(Operator.new(opdata), pos)
            else
                Result.failure
            end
        end
    end
    def args_inside(parser)
        (parser >> (expect(",") >> parser).repeat).opt
    end
    def fcall
        (ident >> expect("(") >> args_inside(expr) >> expect(")")).map do |parsed|
            name = parsed[0]
            args = parsed[1]
            CFCall.new(name, args)
        end
    end
end
