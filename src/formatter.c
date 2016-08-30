
#include <string.h>
#include <captain.h>
#include <gc.h>

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

#if INTERFACE
#include <stdbool.h>
typedef struct {
    bool compress;
    int indent_num;
    char* indent_str;
} FormatOption;
#endif

Token token_openparen() {
    Token token = {};
    token.type = TokenOpenParen;
    token.text = "(";
    return token;
}

Token token_closeparen() {
    Token token = {};
    token.type = TokenCloseParen;
    token.text = ")";
    return token;
}

Token token_openbracket() {
    Token token = {};
    token.type = TokenOpenBracket;
    token.text = "[";
    return token;
}

Token token_closebracket() {
    Token token = {};
    token.type = TokenCloseBracket;
    token.text = "]";
    return token;
}

Token token_openbraces() {
    Token token = {};
    token.type = TokenOpenBraces;
    token.text = "{";
    return token;
}

Token token_closebraces() {
    Token token = {};
    token.type = TokenCloseBraces;
    token.text = "}";
    return token;
}

Token token_comma() {
    Token token = {};
    token.type = TokenComma;
    token.text = ",";
    return token;
}

Token token_colon() {
    Token token = {};
    token.type = TokenColon;
    token.text = ":";
    return token;
}

Token token_semicolon() {
    Token token = {};
    token.type = TokenSemicolon;
    token.text = ";";
    return token;
}

Token token_asterisk() {
    Token token = {};
    token.type = TokenAsterisk;
    token.text = "*";
    return token;
}

Token token_identifier(char* ident) {
    Token token = {};
    token.type = TokenIdentifier;
    token.text = ident;
    return token;
}

Token token_string(char* s) {
    Token token = {};
    token.type = TokenString;
    token.text = s;
    return token;
}

Token token_numeric(char* n) {
    Token token = {};
    token.type = TokenNumeric;
    token.text = n;
    return token;
}

Token token_eos() {
    Token token = {};
    token.type = TokenEndOfStream;
    token.text = NULL;
    return token;
}

void inc_indent(FormatOption* formatopt) {
    formatopt->indent_num++;
}

void dec_indent(FormatOption* formatopt) {
    formatopt->indent_num--;
}

char* generate_indent(FormatOption formatopt) {
    char* s = "";
    for (int i = 0; i < formatopt.indent_num; i++) {
        s = string_concat(s, formatopt.indent_str);
    }
    return s;
}

FormatOption create_formatopt(bool compress) {
    FormatOption formatopt = {};
    formatopt.compress = compress;
    formatopt.indent_num = 0;
    formatopt.indent_str = "    ";
    return formatopt;
}

char* format_tokens(FormatOption formatopt, Tokens* tokens) {
    char* output = "";
    for (int i = 0; i < tokens->length; i++) {
        Token token = tokens->tokens[i];
        switch (token.type) {
            case TokenOpenParen: {
                output = string_concat(output, "(");
            } break;
            case TokenCloseParen: {
                output = string_concat(output, ")");
            } break;
            case TokenOpenBracket: {
                output = string_concat(output, "[");
            } break;
            case TokenCloseBracket: {
                output = string_concat(output, "]");
            } break;
            case TokenOpenBraces: {
                inc_indent(&formatopt);
                if (formatopt.compress) {
                    output = string_concat(output, "{");
                } else {
                    output = string_concat(output, "{\n", generate_indent(formatopt));
                }
            } break;
            case TokenCloseBraces: {
                if (formatopt.compress) {
                    dec_indent(&formatopt);
                    output = string_concat(output, "}");
                } else {
                    int indent_len = strlen(generate_indent(formatopt));
                    dec_indent(&formatopt);
                    output = string_sub(output, 0, -indent_len - 1);
                    output = string_concat(output, "}\n");
                }
            } break;

            case TokenComma: {
                if (formatopt.compress) {
                    output = string_concat(output, ",");
                } else {
                    output = string_concat(output, ", ");
                }
            } break;
            case TokenColon: {
                output = string_concat(output, ":");
            } break;
            case TokenSemicolon: {
                if (formatopt.compress) {
                    output = string_concat(output, ";");
                } else {
                    output = string_concat(output, ";\n", generate_indent(formatopt));
                }
            } break;
            case TokenAsterisk: {
                output = string_concat(output, "*");
            } break;

            case TokenIdentifier: {
                output = string_concat(output, token.text, " ");
            } break;
            case TokenString: {
                output = string_concat(output, "\"", token.text, "\"");
            } break;
            case TokenNumeric: {
                output = string_concat(output, token.text);
            } break;
        }
    }
    return output;
}
