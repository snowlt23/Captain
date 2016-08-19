
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

$special_tokens = [
    "{",
    "}",
    "[",
    "]",
    "(",
    ")",
    ",",
    ";",
    ":",
    " ",
    "\n",
    "\t"
]

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

class Lexer
    def initialize(src)
        @src = src
        @pos = 0
    end
    def skip_spaces()
        while true do
            if  @src[@pos] == " " || @src[@pos] == "\n" || @src[@pos] == "\t" then
                @pos += 1
            else
                break
            end
        end
    end
    def get(len)
        s = @src[@pos, len]
        @pos += len
        return s
    end
    def expect(s)
        self.skip_spaces()
        target = @src[@pos, s.length]
        if target == s
            @pos += s.length
            return true
        else
            return false
        end
    end
    def next_if(s)
        self.skip_spaces()
        target = @src[@pos, s.length]
        if target == s
            @pos += s.length
            return true
        else
            return false
        end
    end
    def special?()
        for token in $special_tokens
            target = @src[@pos, token.length]
            if target == token
                return true
            end
        end
        return false
    end
    def ident()
        self.skip_spaces()
        s = ""
        while !self.special?()
            s += @src[@pos]
            @pos += 1
        end
        if s == ""
            return false
        else
            return s
        end
    end
    def integer()
        self.skip_spaces()
        s = ""
        while true
            c = @src[@pos]
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
    def fcall()
        name = self.ident()
        if !name
            return false
        end
        if !self.expect("(")
            return false
        end
        args = []
        begin
            args.push(self.expr())
        end while self.next_if(",")
        if !self.expect(")")
            return false
        end
        return FCall.new(name, args)
    end
    # def variable()
    #     typ = self.ident()
    #     name = self.ident()
    #     self.expect("=")
    #     expr = self.expr()
    # end
    # def struct()
    # end
    def expr()
        res = self.integer()
        if res
            return res
        end

        res = self.fcall()
        if res
            return res
        end

        res = self.ident()
        if res
            return res
        end

        return false
    end
    # def toplevel()
    # end
end
