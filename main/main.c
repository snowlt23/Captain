
#include <stdio.h>
#include <captain.h>

int main(int argc, char const *argv[]) {
    // char* source = "int main() { char* a = 'c'; printf(\"%d\n\", 1); CAPTAIN_TEST(); }";
    char* source = file_read("example/enum_printer.c");
    Tokens* tokens = parse_string(source);
    // tokens_print(tokens);
    FormatOption formatopt = create_formatopt(false);
    // char* output = format_tokens(formatopt, tokens);
    // printf("%s\n", output);

    // char* tokensstr = format_tokens(formatopt, TOKENS(token_ident("add"), token_openparen(), token_numeric("1"), token_comma(), token_numeric("2"), token_closeparen()));
    // printf("%s\n", tokensstr);

    // Source* srca = create_source_empty();
    // Source* srcb = create_source_empty();
    // source_concat(srca, srcb);

    Source* gen_source = meta_generate(tokens);
    source_print(gen_source, formatopt);
    source_write(gen_source, formatopt, "dist", "enum_printer.generated");

    return 0;
}
