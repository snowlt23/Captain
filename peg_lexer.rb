
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

indent = Indent.new()
puts(indent.block do
    add "if (true) {"
    indent.block do
        add "printf(\"Hello!!\\n\");"
    end
    add "}"
end)

puts(indent.block do
    add "while (false) {"
    indent.block do
        add "printf(\"Hello!!\\n\");"
    end
    add "}"
end)
