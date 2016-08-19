
def is_num?(s)
    if "0".ord <= s.ord && s.ord <= "9".ord
        return true
    else
        return false
    end
end

def args_to_str(args)
    s = args[0].to_s
    for arg in args[1..-1]
        s += "," + arg.to_s
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

class FCall
    attr_accessor :name, :args
    def initialize(name, args)
        @name = name
        @args = args
    end
    def to_s()
        return "#{name}(#{args_to_str(@args)})"
    end
end

class Variable
    attr_accessor :type, :name, :value
    def initialize(type, name, value)
        @type = type
        @name = name
        @value = value
    end
    def to_s()
        return "#{@type} #{@name} = #{@value.to_s}"
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
    def save_pos()
        @save = @pos
    end
    def load_pos()
        @pos = @save
    end
    def store(&block)
        self.save_pos()
        ret = block.call()
        if ret == false
            self.load_pos()
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
                        break
                    end
                    @pos += 1
                end
            elsif self.ahead(2) == "/*"
                @pos += 2
                while true
                    s = self.ahead(2)
                    if s == "*/"
                        break
                    end
                    @pos += 1
                end
            else
                break
            end
        end
        self.save_pos()
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
            type = self.ident()
            if !type
                next false
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

            next Variable.new(type, name, value)
        end
    end
    # def struct()
    # end
    def syntax()
        @syntaxes.each do |name, f|
            self.store do
                id = self.ident()
                if !id
                    next false
                end

                if id == name
                    return f.call(self)
                else
                    next false
                end
            end
        end
        return false
    end
    def expr()
        res = self.syntax()
        if res
            return res
        end

        res = self.number()
        if res
            return res
        end

        res = self.fcall()
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

        return false
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
    def declare()
        res = self.syntax()
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
