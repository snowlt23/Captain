
#include <stdio.h>
#include <string.h>
#include <captain.h>
#include <gc.h>

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

#if INTERFACE

#include <stdbool.h>

typedef enum {
    TokenOpenParen,
    TokenCloseParen,
    TokenOpenBracket,
    TokenCloseBracket,
    TokenOpenBraces,
    TokenCloseBraces,

    TokenComma,
    TokenColon,
    TokenSemicolon,
    TokenAsterisk,

    TokenIdentifier,
    TokenString,
    TokenNumeric,

    TokenEndOfStream,
    TokenUnknown,
} TokenType;

typedef struct {
    TokenType type;
    char* text;
} Token;

typedef struct {
    char* start;
    char* at;
    int length;
} Tokenizer;

typedef struct {
    Token* tokens;
    int length;
} Tokens;

#endif

Tokenizer* create_tokenizer(char* s) {
    Tokenizer* tokenizer = malloc(sizeof(Tokenizer));
    tokenizer->start = s;
    tokenizer->at = s;
    tokenizer->length = strlen(s);
    return tokenizer;
}

bool is_tokenizer_eof(Tokenizer* tokenizer) {
    if (tokenizer->at - tokenizer->start >= tokenizer->length) {
        return true;
    } else {
        return false;
    }
}

bool is_endofline(char c) {
    return ((c == '\n') || (c == '\r'));
}

bool is_whitespace(char c) {
    return ((c == ' ') || (c == '\t') || is_endofline(c));
}

bool is_alpha(char c) {
    return ((('a' <= c) && (c <= 'z')) || (('A' <= c) && (c <= 'Z')));
}

bool is_numeric(char c) {
    return (('0' <= c) && (c <= '9'));
}

void skip_garbage_token(Tokenizer* tokenizer) {
    for (;;) {
        if (is_whitespace(tokenizer->at[0])) {
            tokenizer->at++;
        } else if (tokenizer->at[0] == '/' && tokenizer->at[1] == '/') {
            tokenizer->at += 2;
            while (!is_endofline(tokenizer->at[0])) {
                tokenizer->at++;
            }
        } else if (tokenizer->at[0] == '/' && tokenizer->at[1] == '*') {
            tokenizer->at += 2;
            while (tokenizer->at[0] &&
                !(tokenizer->at[0] == '*' && tokenizer->at[1] == '/'))
            {
                tokenizer->at++;
            }
        } else {
            break;
        }
    }
}

Token get_token(Tokenizer* tokenizer) {
    if (is_tokenizer_eof(tokenizer)) {
        Token token = {};
        token.type = TokenEndOfStream;
        token.text = NULL;
        return token;
    }

    skip_garbage_token(tokenizer);

    Token token = {};
    char c = tokenizer->at[0];
    token.text = string_sub(tokenizer->at, 0, 1);
    tokenizer->at++;
    switch (c) {
        case '\0': {
            token.type = TokenEndOfStream;
        } break;

        case '(': {
            token.type = TokenOpenParen;
        } break;
        case ')': {
            token.type = TokenCloseParen;
        } break;
        case '[': {
            token.type = TokenOpenBracket;
        } break;
        case ']': {
            token.type = TokenCloseBracket;
        } break;
        case '{': {
            token.type = TokenOpenBraces;
        } break;
        case '}': {
            token.type = TokenCloseBraces;
        } break;

        case ',': {
            token.type = TokenComma;
        } break;
        case ':': {
            token.type = TokenColon;
        } break;
        case ';': {
            token.type = TokenSemicolon;
        } break;
        case '*': {
            token.type = TokenAsterisk;
        } break;

        case '"': {
            char* s = "";
            while (tokenizer->at[0] && tokenizer->at[0] != '"') {
                if (tokenizer->at[0] == '\n') {
                    s = string_concat(s, "\\n");
                } else if (tokenizer->at[0] == '\t') {
                    s = string_concat(s, "\\t");
                } else if (tokenizer->at[0] == '\r') {
                    s = string_concat(s, "\\r");
                } else if (tokenizer->at[0] == '\\' && tokenizer->at[1]) {
                    s = string_concat(s, "\\\"");
                    s = string_concat(s, string_sub(tokenizer->at, 0, 1));
                    tokenizer->at++;
                } else {
                    s = string_concat(s, string_sub(tokenizer->at, 0, 1));
                }
                tokenizer->at++;
            }
            tokenizer->at++;
            token.type = TokenString;
            token.text = s;
        } break;

        default: {
            if (is_alpha(c)) {
                char* start = tokenizer->at - 1;
                int len = 1;
                while (is_alpha(tokenizer->at[0]) || is_numeric(tokenizer->at[0]) || tokenizer->at[0] == '_') {
                    tokenizer->at++;
                    len++;
                }
                token.type = TokenIdentifier;
                token.text = string_sub(start, 0, len);
            } else if (is_numeric(c)) {
                char* start = tokenizer->at - 1;
                int len = 1;
                while (is_numeric(tokenizer->at[0]) || tokenizer->at[0] == '.') {
                    tokenizer->at++;
                    len++;
                }
                token.type = TokenNumeric;
                token.text = string_sub(start, 0, len);
            } else {
                token.type = TokenUnknown;
                token.text = NULL;
            }
        } break;
    }

    return token;
}

Tokens* create_tokens() {
    Tokens* tokens = malloc(sizeof(Tokens));
    tokens->tokens = NULL;
    tokens->length = 0;
    return tokens;
}

void tokens_push_token(Tokens* tokens, Token token) {
    tokens->tokens = realloc(tokens->tokens, (tokens->length + 1) * sizeof(Token));
    tokens->tokens[tokens->length] = token;
    tokens->length++;
}

void tokens_print(Tokens* tokens) {
    for (int i = 0; i < tokens->length; i++) {
        printf("%s\n", tokens->tokens[i].text);
    }
}

Tokens* parse_string(char* s) {
    Tokenizer* tokenizer = create_tokenizer(s);
    Tokens* tokens = create_tokens();
    for (;;) {
        Token token = get_token(tokenizer);
        if (token.type == TokenEndOfStream) {
            break;
        } else {
            tokens_push_token(tokens, token);
        }
    }
    return tokens;
}
