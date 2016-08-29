
CC = "gcc"
OPT = "-std=c99"

INCLUDES = [
    "include",
    "thirdparty/BoehmGC/include"
]

SHARED_DIRS = [
    "shares"
]

SHARED_LIBS = [
    "gcmt-dll"
]

SRCS = [
    "src/*.c"
]

TESTS = [
    "test/*.c"
]
