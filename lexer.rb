
def is_num?(s)
    if "0".ord <= s.ord && s.ord <= "9".ord
        return true
    else
        return false
    end
end

def args_to_s(args)
    if args == []
        return ""
    else
        s = args[0].to_s
        for arg in args[1..-1]
            s += "," + arg.to_s
        end
        return s
    end
end
def body_to_s(body)
    s = ""
    for e in body
        s += e.to_s + ";"
    end
    return s
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
    "!"
]

$spaces = [
    " ",
    "\n",
    "\t"
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
    ":"
]

$special_tokens = $separates + $spaces + $operators

class CString
    attr_accessor :str
    def initialize(str)
        @str = str
    end
    def to_s()
        return "\"#{@str}\""
    end
end

class FCall
    attr_accessor :name, :args
    def initialize(name, args)
        @name = name
        @args = args
    end
    def to_s()
        return "#{name}(#{args_to_s(@args)})"
    end
end

class Variable
    attr_accessor :type, :name, :value
    def initialize(const, type, pointer, name, value)
        @const = const
        @type = type
        @pointer = pointer
        @name = name
        @value = value
    end
    def to_s()
        conststr = ""
        if @const
            conststr = "const "
        end
        pointerstr = ""
        if @pointer
            pointerstr = "*"
        end
        if @value
            return "#{conststr}#{@type}#{pointerstr} #{@name} = #{@value.to_s}"
        else
            return "#{conststr}#{@type}#{pointerstr} #{@name}"
        end
    end
end

class Global
    attr_accessor :decl
    def initialize(decl)
        @decl = decl
    end
    def to_s()
        return "#{@decl.to_s};"
    end
end

class Function
    attr_accessor :ret, :name, :args, :body
    def initialize(ret, name, args, body)
        @ret = ret
        @name = name
        @args = args
        @body = body
    end
    def to_s()
        return "#{@ret} #{@name}(#{args_to_s(@args)}) { #{body_to_s(@body)} }"
    end
end

class Operator
    attr_accessor :op
    def initialize(op)
        @op = op
    end
    def to_s()
        return @op
    end
end

class ExprArray
    attr_accessor :exprs
    def initialize(exprs)
        @exprs = exprs
    end
    def self.empty()
        @exprs = []
    end
    def push(expr)
        @exprs.push(expr)
    end
    def to_s()
        return exprs.join(" ")
    end
end

class Paren
    attr_accessor :expr
    def initialize(expr)
        @expr = expr
    end
    def to_s()
        return "(#{@expr.to_s})"
    end
end

class CIf
    attr_accessor :cond, :body
    def initialize(cond, body)
        @cond = cond
        @body = body
    end
    def to_s()
        return "if (#{@cond.to_s}) { #{body_to_s(@body)} }"
    end
end

class CReturn
    attr_accessor :expr
    def initialize(expr)
        @expr = expr
    end
    def to_s()
        return "return #{@expr.to_s}"
    end
end

class Toplevel
end

class Lexer
    def initialize(src)
        @src = src
        @pos = 0
        @save = 0
        @syntaxes = Hash.new()
    end
    def add_syntax(name, &block)
        @syntaxes[name.to_s] = block
    end
    def call_syntax(name)
        self.expect(name)
        return @syntaxes[name.to_s].call(self)
    end
    def method_missing(name)
        return self.call_syntax(name.to_s)
    end
    def get(len)
        if @src.length < @pos + len then
            return false
        else
            s = @src[@pos, len]
            @pos += len
            return s
        end
    end
    def ahead(len)
        if @src.length < @pos + len then
            return false
        else
            return @src[@pos, len]
        end
    end
    def prev(len)
        return @src[@pos - len, len]
    end
    def save_pos()
        @save = @pos
    end
    def load_pos()
        @pos = @save
    end
    def store(&block)
        pos = @pos
        ret = block.call()
        if ret == false
            @pos = pos
            return false
        else
            return ret
        end
    end
    def skip_spaces()
        while true do
            c = self.ahead(1)
            if  c == " " || c == "\n" || c == "\t"
                @pos += 1
            elsif self.ahead(2) == "//"
                @pos += 2
                while true
                    s = self.ahead(1)
                    if s == "\n"
                        @pos += 1
                        break
                    end
                    @pos += 1
                end
            elsif self.ahead(2) == "/*"
                @pos += 2
                while true
                    s = self.ahead(2)
                    if s == "*/"
                        @pos += 2
                        break
                    end
                    @pos += 1
                end
            else
                break
            end
        end
    end
    def special?()
        for token in $special_tokens
            if self.ahead(token.length) == token
                return true
            end
        end
        return false
    end
    def expect(s) # primitive
        self.skip_spaces()
        if self.ahead(s.length) == s
            @pos += s.length
            return true
        else
            return false
        end
    end
    def ident() # primitive
        self.skip_spaces()
        if self.special?()
            return false
        end
        first = self.ahead(1)
        if !first || is_num?(first)
            return false
        end
        s = ""
        while !self.special?()
            c = self.get(1)
            if !c
                break
            end
            s += c
        end
        if s == ""
            return false
        else
            return s
        end
    end
    def integer() # primitive
        self.skip_spaces()
        s = ""
        while true
            c = self.ahead(1)
            if is_num?(c)
                @pos += 1
                s += c
            else
                break
            end
        end
        if s == ""
            return false
        else
            return Integer(s)
        end
    end
    def float() # primitive
        self.store do
            self.skip_spaces()
            s = ""
            dot_flag = false
            while true
                c = self.ahead(1)
                if is_num?(c)
                    @pos += 1
                    s += c
                elsif c == "."
                    dot_flag = true
                    @pos += 1
                    s += c
                else
                    break
                end
            end
            if s == "" || dot_flag == false
                next false
            else
                next Float(s)
            end
        end
    end
    def number()
        self.store do
            res = self.float()
            if res
                next res
            end

            res = self.integer()
            if res
                next res
            end
            next false
        end
    end
    def string()
        self.store do
            self.skip_spaces()

            if !self.expect("\"")
                next false
            end

            s = ""
            escape_flag = false
            while true
                c = self.ahead(1)
                if c == "\"" && escape_flag
                    s += "\""
                elsif c == "\""
                    @pos += 1
                    break
                elsif c == "\\"
                    escape_flag = true
                else
                    s += c
                    escape_flag = false
                end
                @pos += 1
            end
            next CString.new(s)
        end
    end
    def operator()
        self.store do
            opdata = nil
            for op in $operators
                if self.expect(op)
                    opdata = op
                    break
                end
            end
            if opdata != nil
                next Operator.new(opdata)
            else
                next false
            end
        end
    end
    def fcall()
        self.store do
            name = self.ident()
            if !name
                next false
            end

            if !self.expect("(")
                next false
            end

            args = []
            if self.expect(")")
                next FCall.new(name, args)
            end
            begin
                args.push(self.expr())
            end while self.expect(",")

            if !self.expect(")")
                next false
            end

            next FCall.new(name, args)
        end
    end
    def variable()
        self.store do
            const = false
            if self.expect("const")
                const = true
            end

            type = self.ident()
            if !type
                next false
            end
            pointer = false
            if self.expect("*")
                pointer = true
            end

            name = self.ident()
            if !name
                next false
            end

            value = nil
            if self.expect("=")
                value = self.expr()
                if !value
                    next false
                end
            end
            next Variable.new(const, type, pointer, name, value)
        end
    end
    # def struct()
    # end
    def syntax()
        @syntaxes.each do |name, f|
            self.store do
                if self.expect(name)
                    return f.call(self)
                else
                    next false
                end
            end
        end
        return false
    end
    def primexpr()
        res = self.syntax()
        if res
            return res
        end

        res = self.statement()
        if res
            return res
        end

        res = self.number()
        if res
            return res
        end

        res = self.string()
        if res
            return res
        end

        res = self.operator()
        if res
            return res
        end

        res = self.fcall()
        if res
            return res
        end

        res = self.creturn()
        if res
            return res
        end

        res = self.variable()
        if res
            return res
        end

        res = self.ident()
        if res
            return res
        end

        res = self.operator()
        if res
            return res
        end

        res = self.parenexpr()
        if res
            return res
        end

        return false
    end
    def opexpr()
        exprarr = []
        exprarr.push(self.primexpr())
        while true
            e = self.primexpr()
            if !e
                break
            end
            exprarr.push(e)
        end
        if exprarr.size == 1
            return exprarr[0]
        else
            return ExprArray.new(exprarr)
        end
    end
    def parenexpr()
        self.store do
            if self.expect("(")
                e = self.opexpr()
                if !e
                    next false
                end
                if !self.expect(")")
                    next false
                end
                next Paren.new(e)
            else
                next false
            end
        end
    end
    # FIXME: cif
    def cif()
        self.store do
            if !self.expect("if")
                next false
            end
            if !self.expect("(")
                next false
            end

            cond = self.expr()
            if !cond
                next false
            end

            if !self.expect(")")
                next false
            end

            if self.expect("{")
                body = self.body()
                self.expect("}")
                next CIf.new(cond, body)
            else
                e = self.expr()
                if !e
                    next false
                end
                body = [e]
                next CIf.new(cond, body)
            end
        end
    end
    # TODO: cfor
    def cfor()
    end
    # TODO: cwhile
    def cwhile()
    end
    # TODO: cdo
    def cdo()
    end
    # FIXME: statement
    def statement()
        res = self.cif()
        if res
            return res
        end

        return false
    end
    def expr()
        pe = parenexpr()
        if pe
            return pe
        else
            return self.opexpr()
        end
    end
    def creturn()
        self.store do
            if !self.expect("return")
                next false
            end
            e = self.expr()
            if !e
                next false
            end
            next CReturn.new(e)
        end
    end
    def global()
        self.store do
            var = self.variable()
            if !var
                next false
            end
            if !self.expect(";")
                next false
            end
            next Global.new(var)
        end
    end
    def body()
        self.store do
            exprs = []
            while true
                e = self.expr()
                if !e
                    break
                end

                if self.prev(1) == "}"
                elsif !self.expect(";")
                    break
                end
                exprs.push(e)
            end
            next exprs
        end
    end
    def function()
        self.store do
            ret = self.ident()
            if !ret
                next false
            end

            name = self.ident()
            if !name
                next false
            end

            if !self.expect("(")
                next false
            end

            args = []
            if !self.expect(")")
                begin
                    var = self.variable()
                    args.push(var)
                end while self.expect(",")

                if !self.expect(")")
                    next false
                end
            end

            if !self.expect("{")
                next false
            end

            body = self.body()

            if !self.expect("}")
                next false
            end

            next Function.new(ret, name, args, body)
        end
    end
    def declare()
        res = self.syntax()
        if res
            return res
        end

        res = self.function()
        if res
            return res
        end

        res = self.global()
        if res
            return res
        end

        return false
    end
    def toplevel()
        declares = []
        while true
            res = self.declare()
            if !res
                break
            end
            declares.push(res)
        end
        return declares
    end
end
