
#include <stdio.h>
#include <captain.h>

int main(int argc, char const *argv[]) {
    char* source = "int main() { printf(\"%d\n\", 1); }";
    Tokens* tokens = parse_string(source);
    // tokens_print(tokens);
    FormatOption formatopt = create_formatopt(false);
    char* output = format_tokens(formatopt, tokens);
    printf("%s\n", output);
    return 0;
}
