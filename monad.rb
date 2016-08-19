
class Monad
    def *(m)
        self.bind { m }
    end
    def join
        self.bind { |r| r }
    end
end

class Option < Monad
    attr_reader :value
    def initialize(value)
        @value = value
    end
    def self.some(value)
        Option.new(value)
    end
    def self.none
        Option.new(nil)
    end
    def none?
        if @value.nil?
            return true
        else
            return false
        end
    end
    def some?
        if @value.nil?
            return false
        else
            return true
        end
    end
    def get
        return @value
    end
    def bind(&block)
        if self.some?
            ret = block.call(@value)
            unless ret.is_a?(Maybe)
                raise "return value is not Option"
            end
            return ret
        else
            return Option.none
        end
    end
    def map(&block)
        return block.call(@value)
    end
end
