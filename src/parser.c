
#include <captain.h>
#include <gc.h>

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

#if INTERFACE

typedef struct {
    Token name;
    Token* members;
    Token* values;
    int length;
} ParsedEnum;

#endif

ParsedEnum* create_penum() {
    ParsedEnum* parsed = malloc(sizeof(ParsedEnum));
    parsed->name = token_nil();
    parsed->members = NULL;
    parsed->values = NULL;
    parsed->length = 0;
}

ParsedEnum* penum_push(ParsedEnum* penum, Token member, Token value) {
    array_push(penum->members, penum->length, Token, member);
    array_push(penum->values, penum->length, Token, value);
    array_push_finish(penum->length);
}

ParsedEnum* penum_parse(Tokens* source) {
    if (!tokens_expect(source, token_ident("enum"))) {
        return NULL;
    }

    ParsedEnum* penum = create_penum();

    Token name = tokens_get(source);
    if (name.type == TokenIdentifier) {
        tokens_next(source);
    } else {
        name = token_nil();
    }
    penum->name = name;

    if (!tokens_expect(source, token_openbraces())) {
        return NULL;
    }

    // body
    for (;;) {
        if (tokens_expect(source, token_closebraces())) {
            break;
        }
        Token member = tokens_get(source);
        Token value = token_nil();
        tokens_next(source);
        if (tokens_expect(source, token_operator("="))) {
            value = tokens_get(source);
            tokens_next(source);
        }
        penum_push(penum, member, value);
        tokens_expect(source, token_comma());
    }
    tokens_expect(source, token_semicolon());
    return penum;
}

Tokens* penum_to_tokens(ParsedEnum* penum) {
    char* prefix = string_concat(penum->name.text, "_");
    Token macro = token_macro(string_concat("define ", penum->name.text, "(name) ", prefix, " ## name"));

    Tokens* start = TOKENS(token_ident("enum"), penum->name, token_openbraces());

    Tokens* members = create_tokens();
    for (int i = 0; i < penum->length; i++) {
        Token member = penum->members[i];
        Token value = penum->values[i];
        if (value.type == TokenNil) {
            tokens_push_token(members, member);
        } else {
            tokens_push_token(members, token_operator("="));
            tokens_push_token(members, value);
        }
        tokens_push_token(members, token_comma());
    }

    Tokens* end = TOKENS(token_closebraces(), token_semicolon());

    return tokens_concat(TOKENS(macro), start, members, end);
}
