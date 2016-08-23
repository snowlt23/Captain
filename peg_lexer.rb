
require './peg'
include PEG

def args_to_src(indent, args)
    if args
        args.map{|e| e.generate_src(indent)}.join(",")
    else
        ""
    end
end

def body_to_src(indent, body)
    first = ""
    if !indent.compress
        first = indent.gen
    end
    first + indent.start do |fs|
        for e in body
            fs.add e.generate_src(indent) + ";"
        end
    end
end

def is_num?(s)
    if "0".ord <= s.ord && s.ord <= "9".ord
        return true
    else
        return false
    end
end

def top_generate_src(parsed, compress: false)
    s = ""
    indent = Indent.new(compress: compress)
    for e in parsed.value
        if compress
            s += e.generate_src(indent)
        else
            s += e.generate_src(indent) + "\n\n"
        end
    end
    s
end

$operators = [
    "+=",
    "-=",
    "*=",
    "/=",
    "%=",
    "<<=",
    ">>=",
    "&=",
    "^=",
    "|=",
    "++",
    "--",
    "+",
    "-",
    "*",
    "/",
    "%",
    ".",
    "->",
    "==",
    "!=",
    "=",
    "&&",
    "||",
    "&",
    "|",
    "^",
    "~",
    "<<",
    ">>",
    "<=",
    ">=",
    "<",
    ">",
    "?",
    "!",
]

$spaces = [
    " ",
    "\n",
    "\t",
]

$separates = [
    "{",
    "}",
    "[",
    "]",
    "(",
    ")",
    ",",
    ";",
    ":",
    "\"",
]

$special_tokens = $separates + $spaces + $operators

class FormatString
    attr_accessor :strings
    def initialize(indent)
        @indent = indent
        @strings = []
    end
    def gen
        @indent.gen
    end
    def get
        if @indent.compress
            @strings.join("").sub(Regexp.new(self.gen), "")
        else
            @strings.join("\n").sub(Regexp.new(self.gen), "")
        end
    end
    def add(s)
        if @indent.compress
            @strings.push(s)
        else
            @strings.push(self.gen + s)
        end
    end
    def add_body(s)
        @strings.push(s)
    end
end

class Indent
    attr_accessor :num, :indent, :compress, :current
    def initialize(indent: "    ", compress: false)
        @num = 0
        @indent = indent
        @compress = compress
    end
    def gen
        s = ""
        for i in 0..@num-1
            s += @indent
        end
        s
    end
    def start
        fs = FormatString.new(self)
        yield(fs)
        fs.get()
    end
    def block
        @num += 1
        yield
        @num -= 1
    end
end

class String
    def generate_src(indent)
        self
    end
end

class Integer
    def generate_src(indent)
        self.to_s
    end
end

class NilClass
    def generate_src(indent)
        ""
    end
end

class Float
    def generate_src(indent)
        self.to_s
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
        "#{@name}(#{args_to_src(indent, @args)})"
    end
end

class CInitExpr
    attr_accessor :exprs
    def initialize(exprs)
        @exprs = exprs
    end
    def generate_src(indent)
        "{ #{args_to_src(indent, @exprs)} }"
    end
end

class CType
    def initialize(const, prefix, name, pointer)
        @const = const
        @prefix = prefix
        @name = name
        @pointer = pointer
    end
    def generate_src(indent)
        conststr = ""
        if @const
            conststr = "const "
        end
        prefixstr = ""
        if @prefix
            prefixstr = "#{@prefix} "
        end
        pointerstr = ""
        if @pointer
            pointerstr = "*"
        end
        "#{conststr}#{prefixstr}#{@name}#{pointerstr}"
    end
end

class CVariable
    attr_accessor :const, :type, :pointer, :name, :value
    def initialize(type, name, value)
        @type = type
        @name = name
        @value = value
    end
    def generate_src(indent)
        valuestr = ""
        if @value
            valuestr = " = #{@value.generate_src(indent)}"
        end
        "#{@type.generate_src(indent)} #{@name}#{valuestr}"
    end
end

class CFPointer
    attr_accessor :ret, :name, :args
    def initialize(ret, name, args, value)
        @ret = ret
        @name = name
        @args = args
        @value = value
    end
    def generate_src(indent)
        valuestr = ""
        if @value
            valuestr = " = #{@value.generate_src(indent)}"
        end
        "#{ret.generate_src(indent)} (*#{@name.generate_src(indent)})(#{args_to_src(indent, @args)})#{valuestr}"
    end
end

class CIf
    attr_accessor :cond, :body
    def initialize(cond, body)
        @cond = cond
        @body = body
    end
    def generate_src(indent)
        indent.start do |fs|
            fs.add "if (#{@cond.generate_src(indent)}) {"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "}"
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
        indent.start do |fs|
            fs.add "for (#{@init.generate_src(indent)};#{@cond.generate_src(indent)};#{@update.generate_src(indent)}) {"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "}"
        end
    end
end

class CWhile
    attr_accessor :cond, :body
    def initialize(cond, body)
        @cond = cond
        @body = body
    end
    def generate_src(indent)
        indent.start do |fs|
            fs.add "while (#{@cond.generate_src(indent)}) {"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "}"
        end
    end
end

class CDo
    attr_accessor :cond, :body
    def initialize(cond, body)
        @cond = cond
        @body = body
    end
    def generate_src(indent)
        indent.start do |fs|
            fs.add "do {"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "} while (#{@cond.generate_src(indent)})"
        end
    end
end

class CReturn
    attr_accessor :expr
    def initialize(expr)
        @expr = expr
    end
    def generate_src(indent)
        "return #{@expr.generate_src(indent)}"
    end
end

class CExprArray
    attr_accessor :exprs
    def initialize(exprs)
        @exprs = exprs
    end
    def generate_src(indent)
        exprs.map{|e| e.generate_src(indent)}.join(" ")
    end
end

class CParen
    attr_accessor :expr
    def initialize(expr)
        @expr = expr
    end
    def generate_src(indent)
        "(#{@expr.generate_src(indent)})"
    end
end

class CGlobal
    attr_accessor :var
    def initialize(var)
        @var = var
    end
    def generate_src(indent)
        indent.start do |fs|
            fs.add "#{@var.generate_src(indent)};"
        end
    end
end

class CTypedef
    attr_accessor :from, :to
    def initialize(from, to)
        @from = from
        @to = to
    end
    def generate_src(indent)
        "typedef #{@from.generate_src(indent)} #{@to.generate_src(indent)};"
    end
end

class CFPrototype
    attr_accessor :ret, :pointer, :name, :args
    def initialize(ret, name, args)
        @ret = ret
        @name = name
        @args = args
    end
    def generate_src(indent)
        indent.start do |fs|
            fs.add "#{@ret.generate_src(indent)} #{@name}(#{args_to_src(@args)});"
        end
    end
end

class CFunction
    attr_accessor :ret, :pointer, :name, :args, :body
    def initialize(ret, name, args, body)
        @ret = ret
        @name = name
        @args = args
        @body = body
    end
    def generate_src(indent)
        indent.start do |fs|
            fs.add "#{@ret.generate_src(indent)} #{@name}(#{args_to_src(indent, @args)}) {"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "}"
        end
    end
end

class CUnion
    attr_accessor :name, :body
    def initialize(name, body)
        @name = name
        @body = body
    end
    def generate_src(indent)
        namestr = ""
        if @name
            namestr = "#{@name} "
        end
        indent.start do |fs|
            fs.add "union #{namestr}{"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "}"
        end
    end
end

class CStruct
    attr_accessor :name, :body
    def initialize(name, body)
        @name = name
        @body = body
    end
    def generate_src(indent)
        namestr = ""
        if @name
            namestr = "#{@name} "
        end
        indent.start do |fs|
            fs.add "struct #{namestr}{"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "}"
        end
    end
end

class CEnumValue
    attr_accessor :name, :value
    def initialize(name, value)
        @name = name
        @value = value
    end
    def generate_src(indent)
        valuestr = ""
        if @value
            valuestr = " = #{@value.generate_src(indent)}"
        end
        "#{@name.generate_src(indent)}#{valuestr}"
    end
end

class CEnum
    attr_accessor :name, :body
    def initialize(name, body)
        @name = name
        @body = body
    end
    def generate_src(indent)
        namestr = ""
        if @name
            namestr = "#{@name} "
        end
        indent.start do |fs|
            fs.add "enum #{namestr}{"
            indent.block do
                fs.add_body body_to_src(indent, @body)
            end
            fs.add "}"
        end
    end
end

class Lexer
    def linecomment
        Parser.new do |input, pos|
            s = get(input, pos, 2)
            if !s
                Result.failure
            elsif s == "//"
                pos += 2
                while true
                    c = get(input, pos, 1)
                    pos += 1
                    if !c
                        break
                    elsif c == "\n"
                        break
                    end
                end
                Result.success(nil, pos)
            else
                Result.failure
            end
        end
    end
    def blockcomment
        Parser.new do |input, pos|
            s = get(input, pos, 2)
            if !s
                Result.failure
            elsif s == "/*"
                pos += 2
                while true
                    c = get(input, pos, 2)
                    if !c
                        next Result.failure
                    elsif c == "*/"
                        pos += 2
                        break
                    end
                    pos += 1
                end
                Result.success(nil, pos)
            else
                Result.failure
            end
        end
    end
    def comment
        linecomment / blockcomment
    end
    def space
        (str("\s") / str("\t") / str("\n") / comment).repeat1
    end
    def sp
        space.opt.garbage
    end
    def expect(s) # primitive
        (sp >> str(s)).garbage
    end
    def next_if(s) # primitive
        (sp >> str(s)).result do |res, pos|
            if res.success?
                Result.success(true, res.pos)
            elsif res.failure?
                Result.success(false, pos)
            elsif res.garbage?
                res
            end
        end
    end
    def special?(input, pos)
        for token in $special_tokens
            if get(input, pos, token.length) == token
                return true
            end
        end
        return false
    end
    def ident # primitive
        sp >> Parser.new do |input, pos|
            if special?(input, pos)
                next Result.failure
            end
            first = get(input, pos, 1)
            if !first || is_num?(first)
                next Result.failure
            end
            s = ""
            while !special?(input, pos)
                c = get(input, pos, 1)
                if !c
                    break
                end
                s += c
                pos += 1
            end
            if s == ""
                next Result.failure
            else
                next Result.success(s, pos)
            end
        end
        # sp >> (match('[a-zA-Z]') >> match('[a-zA-Z0-9]').repeat).concat
    end
    def integer # primitive
        sp >> match('[0-9]').repeat1.concat.map do |parsed|
            Integer(parsed)
        end
    end
    def float # primitive
        (sp >> match('[0-9]').repeat1 >> str(".") >> match('[0-9]').repeat1).concat.map do |parsed|
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
                c = get(input, pos, 1)
                if !c
                    break
                elsif c == "\"" && escape_flag
                    s += "\""
                elsif c == "\""
                    pos += 1
                    break
                elsif c == "\\"
                    escape_flag = true
                elsif escape_flag
                    s += "\\" + c
                    escape_flag = false
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
                Result.success(COperator.new(opdata), pos)
            else
                Result.failure
            end
        end
    end
    def args_inside(parser)
        ((parser >> (expect(",") >> parser).repeat).opt >> expect(",").opt.garbage).map do |parsed|
            if !parsed
                parsed
            elsif parsed.size > 1
                parsed[1].insert(0, parsed[0])
            else
                parsed
            end
        end
    end
    def fcall
        (ident >> expect("(") >> args_inside(expr) >> expect(")")).map do |parsed|
            name = parsed[0]
            args = parsed[1]
            CFCall.new(name, args)
        end
    end
    def init_expr
        (expect("{") >> args_inside(expr) >> expect("}")).map do |parsed|
            CInitExpr.new(parsed)
        end
    end
    def type
        (next_if("const") >>
        next_if("struct") >> next_if("union") >> next_if("enum") >> next_if("unsigned") >> next_if("signed") >>
        ident >> next_if("*")).map do |parsed|
            const = parsed[0]

            struct = parsed[1]
            union = parsed[2]
            enum = parsed[3]
            unsigned = parsed[4]
            signed = parsed[5]
            prefix = nil
            if struct
                prefix = "struct"
            elsif union
                prefix = "union"
            elsif enum
                prefix = "enum"
            elsif unsigned
                prefix = "unsigned"
            elsif signed
                prefix = "signed"
            end

            name = parsed[6]
            pointer = parsed[7]
            CType.new(const, prefix, name, pointer)
        end
    end
    def variable
        (type >> ident >> (expect("=") >> expr).opt).map do |parsed|
            type = parsed[0]
            name = parsed[1]
            value = parsed[2]
            CVariable.new(type, name, value)
        end / fpointer
    end
    def fpointer
        (type >> expect("(") >> expect("*") >> ident >> expect(")") >>
        expect("(") >> args_inside(lazy(lambda{variable}) / type) >> expect(")") >> (expect("=") >> expr).opt).map do |parsed|
            ret = parsed[0]
            name = parsed[1]
            args = parsed[2]
            value = parsed[3]
            CFPointer.new(ret, name, args, value)
        end
    end
    def body
        (expr >> expect(";").opt.garbage).repeat
    end
    def block
        expect("{") >> body >> expect("}")
    end
    def statement_block
        (expr / block).map do |parsed|
            if parsed.instance_of?(Array)
                parsed
            else
                [parsed]
            end
        end
    end
    def cif
        (expect("if") >> expect("(") >> expr >> expect(")") >> statement_block).map do |parsed|
            cond = parsed[0]
            body = parsed[1]
            CIf.new(cond, body)
        end
    end
    def cfor
        (expect("for") >> expect("(") >>
        expr.opt >> expect(";") >> expr.opt >> expect(";") >> expr.opt >>
        expect(")") >> statement_block).map do |parsed|
            init = parsed[0]
            cond = parsed[1]
            update = parsed[2]
            body = parsed[3]
            CFor.new(init, cond, update, body)
        end
    end
    def cwhile
        (expect("while") >> expect("(") >> expr >> expect(")") >> statement_block).map do |parsed|
            cond = parsed[0]
            body = parsed[1]
            CWhile.new(cond, body)
        end
    end
    def cdo
        (expect("do") >> block >> expect("while") >> expect("(") >> expr >> expect(")")).map do |parsed|
            body = parsed[0..-2]
            cond = parsed[1]
            CDo.new(cond, body)
        end
    end
    def statement
        cif / cfor / cwhile / cdo
    end
    def creturn
        (expect("return") >> expr).map do |parsed|
            CReturn.new(parsed)
        end
    end
    def primexpr
        statement / number / string / character / operator / variable / fcall / creturn / init_expr / ident / lazy(lambda{parenexpr})
    end
    def exprarray
        primexpr.repeat1.map do |parsed|
            if parsed.size == 1
                parsed[0]
            else
                CExprArray.new(parsed)
            end
        end
    end
    def parenexpr
        (expect("(") >> exprarray >> expect(")")).map do |parsed|
            CParen.new(parsed)
        end
    end
    def expr
        lazy(lambda { statement / parenexpr / exprarray })
    end
    def fdecl
        type >> ident >> expect("(") >> args_inside(variable) >> expect(")")
    end
    def fprototype
        (fdecl >> expect(";")).map do |parsed|
            ret = parsed[0]
            name = parsed[1]
            args = parsed[2]
            CFPrototype.new(ret, name, args)
        end
    end
    def function
        (fdecl >> block).map do |parsed|
            ret = parsed[0]
            name = parsed[1]
            args = parsed[2]
            body = parsed[3]
            CFunction.new(ret, name, args, body)
        end
    end
    def typebody
        ((lazy(lambda{union}) / lazy(lambda{struct}) / variable) >> expect(";")).repeat
    end
    def union
        (expect("union") >> ident.opt >> expect("{") >> typebody >> expect("}")).map do |parsed|
            name = parsed[0]
            body = parsed[1]
            CUnion.new(name, body)
        end
    end
    def struct
        (expect("struct") >> ident.opt >> expect("{") >> typebody >> expect("}")).map do |parsed|
            name = parsed[0]
            body = parsed[1]
            CStruct.new(name, body)
        end
    end
    def enum_value
        (ident >> (expect("=") >> integer).opt).map do |parsed|
            name = parsed[0]
            value = parsed[1]
            CEnumValue.new(name, value)
        end
    end
    def enum
        (expect("enum") >> ident.opt >> expect("{") >>
        args_inside(enum_value) >>
        expect("}")).map do |parsed|
            name = parsed[0]
            body = parsed[1]
            CEnum.new(name, body)
        end
    end
    def toptype
        struct / union / enum / type
    end
    def global
        ((struct / union / enum / variable) >> expect(";")).map do |parsed|
            CGlobal.new(parsed)
        end
    end
    def typedef
        (expect("typedef") >> toptype >> ident >> expect(";")).map do |parsed|
            from = parsed[0]
            to = parsed[1]
            CTypedef.new(from, to)
        end
    end
    # def extern
    # end
    def declare
        typedef / global / fprototype / function
    end
    def toplevel
        declare.repeat
    end
    def parse(src)
        toplevel.exec(src)
    end
end
