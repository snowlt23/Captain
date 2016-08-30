
#include <stdio.h>
#include <captain.h>

int main(int argc, char const *argv[]) {
    char* source = "int main() { printf(\"%d\n\", 1); CAPTAIN_TEST(); }";
    Tokens* tokens = parse_string(source);
    // tokens_print(tokens);
    FormatOption formatopt = create_formatopt(false);
    // char* output = format_tokens(formatopt, tokens);
    // printf("%s\n", output);

    // char* tokensstr = format_tokens(formatopt, TOKENS(token_ident("add"), token_openparen(), token_numeric("1"), token_comma(), token_numeric("2"), token_closeparen()));
    // printf("%s\n", tokensstr);

    Tokens* gened_tokens = meta_generate(tokens);
    char* gened_output = format_tokens(formatopt, gened_tokens);
    printf("%s\n", gened_output);

    return 0;
}
