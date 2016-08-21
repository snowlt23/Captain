
require './peg'
include PEG

def args_to_src(indent, args)
    args.map{|e| e.generate_src(indent)}.join(",")
end

def body_to_src(indent, body)
    s = ""
    for e in body
        s += e.generate_src(indent) + ";"
        if !indent.compress
            s += "\n"
        end
    end
    s
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
    def start(&f)
        self.instance_eval(&f)
        s = @current
        @current = ""
        s
    end
    def block(&f)
        @num += 1
        self.instance_eval(&f)
        @num -= 1
        s = @current
        @current = ""
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

class CVariable
    attr_accessor :const, :type, :pointer, :name, :value
    def initialize(const, type, pointer, name, value)
        @const = const
        @type = type
        @pointer = pointer
        @name = name
        @value = value
    end
    def generate_src(indent)
        conststr = ""
        if @const
            conststr = "const "
        end
        pointerstr = ""
        if @pointer
            pointerstr = "*"
        end
        valuestr = ""
        if @value
            valuestr = " = #{@value.generate_src(indent)}"
        end
        "#{conststr}#{@type}#{pointerstr} #{@name}#{valuestr}"
    end
end

class CIf
    attr_accessor :cond, :body
    def initialize(cond, body)
        @cond = cond
        @body = body
    end
    def generate_src(indent)
        indent.start do
            add "if (#{@cond.generate_src(indent)}) {"
            add body_to_src(@body)
            add "}"
        end
    end
end

class CFor
    attr_accessor :init, :cond, :update, :body
    def initialize(init, cond, update, body)
        @init = init
        @cond = cond
        @update = update
        @body = body
    end
    def generate_src(indent)
        indent.start do
            add "for (#{@init.generate_src(indent)};#{@cond.generate_src(indent)};#{@update.generate_src(indent)}) {"
            add body_to_src(@body)
            add "}"
        end
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
    def next_if(s) # primitive
        (sp >> str(s)).result do |res|
            if res.success?
                Result.success(true, res.pos)
            elsif res.failure?
                Result.success(false, res.pos)
            elsif res.garbage?
                res
            end
        end
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
    def variable
        (next_if("const") >> ident >> next_if("*") >> ident >> (expect("=") >> expr).opt).map do |parsed|
            const = parsed[0]
            type = parsed[1]
            pointer = parsed[2]
            name = parsed[3]
            value = parsed[4]
            CVariable.new(const, type, pointer, name, value)
        end
    end
    def body
        (expr >> expect(";").opt).repeat
    end
    def block
        expect("{") >> body >> expect("}")
    end
    def cif
        (expect("if") >> expect("(") >> expr >> expect(")") >> (expr / block)).map do |parsed|
            cond = parsed[0]
            body = parsed[1]
            CIf.new(cond, body)
        end
    end
    def cfor
        (expect("for") >> expect("(") >>
        expr.opt >> expect(";") >> expr.opt >> expect(";") >> expr.opt >>
        expect(")") >> (expr / block)).map do |parsed|
            init = parsed[0]
            cond = parsed[1]
            update = parsed[2]
            body = parsed[3]
            CFor.new(init, cond, update, body)
        end
    end
    # TODO: statement
    def statement
    end
    # TODO: primexpr
    def primexpr
    end
end
