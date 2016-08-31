
#include <stdio.h>
#include <string.h>
#include <captain.h>
#include <gc.h>

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

#if INTERFACE

typedef Tokens* (*GeneratorFn)(Tokens* source);

typedef struct {
    Token* hook_tokens;
    GeneratorFn* generators;
    int length;
} Generator;
#endif

bool expect_token(Token token, char* s) {
    if (strcmp(token.text, s) == 0) {
        return true;
    } else {
        return false;
    }
}

bool token_equal(Token a, Token b) {
    if (a.type == b.type && strcmp(a.text, b.text) == 0) {
        return true;
    } else {
        return false;
    }
}

Generator* create_generator() {
    Generator* generator = malloc(sizeof(Generator));
    generator->hook_tokens = NULL;
    generator->generators = NULL;
    generator->length = 0;
    return generator;
}

void register_generator(Generator* generator, Token hook_token, GeneratorFn fn) {
    array_push(generator->hook_tokens, generator->length, Token, hook_token);
    array_push(generator->generators, generator->length, GeneratorFn, fn);
    array_push_finish(generator->length);
}

int get_hook(Generator* generator, Token token) {
    for (int i = 0; i < generator->length; i++) {
        if (token_equal(generator->hook_tokens[i], token)) {
            return i;
        }
    }
    return -1;
}

bool is_hook(int hook) {
    if (hook == -1) {
        return false;
    } else {
        return true;
    }
}

Tokens* call_generator(Generator* generator, Tokens* tokens, int index) {
    return generator->generators[index](tokens);
}

Tokens* generator_eval(Generator* generator, Tokens* tokens) {
    Token token = tokens_get(tokens);
    int hook = get_hook(generator, token);
    if (is_hook(hook)) {
        Tokens* called = call_generator(generator, tokens, hook);
        if (called == NULL) {
            return NULL;
        } else {
            return generator_exec(generator, called);
        }
    } else {
        return NULL;
    }
}

Tokens* generator_exec(Generator* generator, Tokens* tokens) {
    Tokens* ret = create_tokens();
    for (;;) {
        Tokens* evaluated = generator_eval(generator, tokens);
        if (evaluated == NULL) {
            if (is_tokens_end(tokens)) {
                break;
            } else {
                Token next = tokens_get(tokens);
                tokens_push_token(ret, next);
                tokens_next(tokens);
            }
        } else {
            ret = tokens_concat(ret, evaluated);
        }
    }
    return ret;
}

Tokens* replace_captiain_test(Tokens* source) {
    tokens_next(source);
    return TOKENS(token_ident("replaced_test"));
}

Tokens* printable_enum_generator(Tokens* source) {
    tokens_next(source);
    char* s = "";
    ParsedEnum* penum = penum_parse(source);
    if (penum == NULL) {
        return NULL;
    }
    s = string_concat(s, "void ", penum->name.text, "_print", "(enum ", penum->name.text, " value) {");
    s = string_concat(s, "switch (value) {");
    for (int i = 0; i < penum->length; i++) {
        Token member = penum->members[i];
        s = string_concat(s, "case ", member.text, ":", "{", "printf(\"", member.text, "\");", "} break;");
    }
    s = string_concat(s, "}}");
    return tokens_concat(penum_to_tokens(penum), parse_string(s));
}

Tokens* annotation_generator(Tokens* source) {
    tokens_next(source);
    return create_tokens();
}

void register_std_generator(Generator* generator) {
    register_generator(generator, token_ident("CAPTAIN_TEST"), &replace_captiain_test);
    register_generator(generator, token_ident("printable"), &printable_enum_generator);
    register_generator(generator, token_operator("@"), &annotation_generator);
}

Tokens* meta_generate(Tokens* tokens) {
    Generator* generator = create_generator();
    register_std_generator(generator);
    return generator_exec(generator, tokens);
}
