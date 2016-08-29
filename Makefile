
CC = gcc
OPT = -std=c99

INCLUDES =
INCLUDES += -Iinclude/

SRCS = src/*.c
TESTS = test/*.c

build: gen-header
	$(CC) -o dist/captain $(OPT) $(INCLUDES) $(SRCS) main/main.c

test: gen-header gen-test-header
	$(CC) -o dist/captain-test $(OPT) $(INCLUDES) $(SRCS) $(TESTS) main/test.c

gc-benchmark: gen-header gen-test-header
	$(CC) -o dist/gc-benchmark $(OPT) $(INCLUDES) $(SRCS) main/gc_benchmark.c

gen-header:
	makeheaders -h $(SRCS) > include/captain.h

gen-test-header:
	makeheaders -h $(TESTS) > include/captain_test.h
