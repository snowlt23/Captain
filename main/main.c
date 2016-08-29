
#include <captain.h>

int main(int argc, char const *argv[]) {
    char* source = "int main() { printf(\"%d\n\", 1); }";
    Tokens* tokens = parse_string(source);
    tokens_print(tokens);
    return 0;
}
