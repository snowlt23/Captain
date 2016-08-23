
module PEG
    class SourcePos
        attr_accessor :line, :column
        def initialize(line, column)
            @line = line
            @column = column
        end
        def self.calc(s, pos)
            line = 1
            column = 1
            for i in 0..pos-1
                if s[i] == "\n"
                    line += 1
                    column = 1
                else
                    column += 1
                end
            end
            SourcePos.new(line, column)
        end
    end
    # type: success, failure, garbage
    class Result
        attr_accessor :type, :value, :pos
        def initialize(type, value, pos)
            @type = type
            @value = value
            @pos = pos
        end
        def self.success(value, pos)
            return Result.new("success", value, pos)
        end
        def success?
            if @type == "success"
                return true
            else
                return false
            end
        end
        def self.failure
            return Result.new("failure", nil, nil)
        end
        def failure?
            if @type == "failure"
                return true
            else
                return false
            end
        end
        def self.garbage(pos)
            return Result.new("garbage", nil, pos)
        end
        def garbage?
            if @type == "garbage"
                return true
            else
                return false
            end
        end
        def /(that)
            if self.success?
                return self
            elsif that.success?
                return that
            else
                return Result.failure
            end
        end
        def >>(that)
            if self.success?
                if that.success?
                    if self.value.instance_of?(Array)
                        Result.success(self.value + [that.value], that.pos)
                    else
                        Result.success([self.value, that.value], that.pos)
                    end
                elsif that.failure?
                    Result.failure
                elsif that.garbage?
                    Result.success(self.value, that.pos)
                end
            elsif self.failure?
                Result.failure
            elsif self.garbage?
                if that.success?
                    that
                elsif that.failure?
                    Result.failure
                elsif that.garbage?
                    that
                end
            end
        end
        def map(&block)
            if self.success?
                return Result.success(block.call(@value), @pos)
            else
                return self
            end
        end
    end
    class Parser
        def initialize(&f)
            @f = f
        end
        def parse(input, pos)
            @f.call(input, pos)
        end
        def exec(input)
            self.parse(input, 0)
        end
        def /(that)
            Parser.new do |input, pos|
                self.parse(input, pos) / that.parse(input, pos)
            end
        end
        def >>(that)
            Parser.new do |input, pos|
                left = self.parse(input, pos)
                if left.failure?
                    Result.failure
                else
                    right = that.parse(input, left.pos)
                    left >> right
                end
            end
        end
        def repeat
            Parser.new do |input, pos|
                ret = []
                while true
                    res = self.parse(input, pos)
                    if res.success?
                        ret << res.value
                        pos = res.pos
                    elsif res.failure?
                        break
                    elsif res.garbage?
                        pos = res.pos
                    end
                end
                Result.success(ret, pos)
            end
        end
        def repeat1
            (self >> self.repeat).map do |parsed|
                parsed[1].insert(0, parsed[0])
            end
        end
        def opt
            Parser.new do |input, pos|
                res = self.parse(input, pos)
                if res.success?
                    res
                elsif res.failure?
                    Result.success(nil, pos)
                elsif res.garbage?
                    res
                end
            end
        end
        def not
            Parser.new do |input, pos|
                res = self.parse(input, pos)
                if res.success?
                    Result.failure
                elsif res.failure?
                    Result.success(nil, res.pos)
                elsif res.garbage?
                    Result.failure
                end
            end
        end
        def garbage
            Parser.new do |input, pos|
                res = self.parse(input, pos)
                if res.success?
                    Result.garbage(res.pos)
                elsif res.failure?
                    Result.failure
                elsif res.garbage?
                    res
                end
            end
        end
        def map(&block)
            Parser.new do |input, pos|
                res = self.parse(input, pos)
                if res.success?
                    Result.success(block.call(res.value), res.pos)
                elsif res.failure?
                    Result.failure
                elsif res.garbage?
                    res
                end
            end
        end
        def result(&block)
            Parser.new do |input, pos|
                res = self.parse(input, pos)
                block.call(res, pos)
            end
        end
        def concat # mapper
            self.map do |parsed|
                parsed.join("")
            end
        end
        def debug_print # mapper
            self.map do |parsed|
                p parsed
                parsed
            end
        end
        def except(msg: "")
            Parser.new do |input, pos|
                res = self.parse(input, pos)
                if res.success?
                    res
                elsif res.failure?
                    srcpos = SourcePos.calc(input, pos)
                    raise "(#{srcpos.line}, #{srcpos.column}) parse error: #{msg}"
                elsif res.garbage?
                    res
                end
            end
        end
    end
    def get(s, pos, len)
        if s.length <= pos + len
            return false
        else
            return s[pos, len]
        end
    end
    def str(s)
        Parser.new do |input, pos|
            if input.length <= pos + s.length
                Result.failure
            elsif input[pos, s.length] == s
                Result.success(s, pos + s.length)
            else
                Result.failure
            end
        end
    end
    def lazy(f)
        Parser.new do |input, pos|
            f.call.parse(input, pos)
        end
    end
    def match(s)
        Parser.new do |input, pos|
            if input.length <= pos
                Result.failure
            else
                reg = Regexp.new("^"+s)
                res = reg.match(input[pos..-1])
                if res
                    Result.success(res.to_s, pos + res.end(0))
                else
                    Result.failure
                end
            end
        end
    end
end
