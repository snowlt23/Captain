
require "./build_info"

def add_prefix_join(prefix, arr)
    prearr = []
    arr.each do |e|
        prearr.push(prefix + e)
    end
    prearr.join(" ")
end

def wildcard_files(arr)
    test_arr = []
    arr.each do |e|
        test_arr += Dir.glob(e)
    end
    test_arr.join(" ")
end

PRE_INCLUDES = add_prefix_join("-I", INCLUDES)
PRE_SHARED_DIRS = add_prefix_join("-L", SHARED_DIRS)
PRE_SHARED_LIBS = add_prefix_join("-l", SHARED_LIBS)

PRE_SRCS = wildcard_files(SRCS)
PRE_TESTS = wildcard_files(TESTS)

task :all => [:build, :test]
task :default => :build

task :build => [:gen_header, :shares_to_dist] do
    sh "#{CC} -o dist/captain #{OPT} #{PRE_INCLUDES} #{PRE_SHARED_DIRS} #{PRE_SHARED_LIBS} #{PRE_SRCS} main/main.c"
end

task :test => [:gen_header, :gen_test_header, :shares_to_dist] do
    sh "#{CC} -o dist/captain_test #{OPT} #{PRE_INCLUDES} #{PRE_SHARED_DIRS} #{PRE_SHARED_LIBS} #{PRE_SRCS} #{PRE_TESTS} main/test.c"
end

task :gen_header do
    sh "makeheaders -h #{PRE_SRCS} > include/captain.h"
end

task :gen_test_header do
    sh "makeheaders -h #{PRE_TESTS} > include/captain_test.h"
end

task :shares_to_dist do
    Dir.glob("shares/*") do |file|
        cp file, "dist/#{File.basename(file)}"
    end
end
