
#include <string.h>
#include <captain.h>

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
    generator->length--;
    array_push(generator->generators, generator->length, GeneratorFn, fn);
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

void register_std_generator(Generator* generator) {
    register_generator(generator, token_ident("CAPTAIN_TEST"), &replace_captiain_test);
}

Tokens* meta_generate(Tokens* tokens) {
    Generator* generator = create_generator();
    register_std_generator(generator);
    return generator_exec(generator, tokens);
}
