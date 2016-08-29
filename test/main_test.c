
#include <stdio.h>
#include <greatest.h>
#include <captain.h>

TEST tokenizer_test() {
    char* source = "int main() { printf(\"%d\n\", 1); }";
    Tokens* tokens = parse_string(source);
    tokens_print(tokens);
}

SUITE(main_suite) {
    RUN_TEST(tokenizer_test);
}
