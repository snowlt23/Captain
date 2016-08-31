
#include <stdio.h>
#include <string.h>
#include <captain.h>
#include <gc.h>

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

#if INTERFACE

#include <stdlib.h>

typedef struct {
    Tokens* source;
    Tokens* toplevel;
    Tokens* header;
} Source;

#define source_concat(...) \
    source_concat_inside( \
        (Source*[]){ __VA_ARGS__ }, \
        sizeof((Source*[]){ __VA_ARGS__ }) / sizeof(Source*) \
    )

#endif

Source* source_concat_inside(Source** list, size_t len) {
    Source* newsource = create_source_empty();
    for (int i = 0; i < len; i++) {
        newsource->source = tokens_concat(newsource->source, list[i]->source);
        newsource->toplevel = tokens_concat(newsource->toplevel, list[i]->toplevel);
        newsource->header = tokens_concat(newsource->header, list[i]->header);
    }
    return newsource;
}

Source* create_source_empty() {
    Source* source = malloc(sizeof(Source));
    source->source = create_tokens();
    source->toplevel = create_tokens();
    source->header = create_tokens();
    return source;
}

Source* create_source(Tokens* src, Tokens* toplevel, Tokens* header) {
    Source* source = malloc(sizeof(Source));
    source->source = src;
    source->toplevel = toplevel;
    source->header = header;
    return source;
}

void source_print(Source* source, FormatOption formatopt) {
    printf("source:\n%s\n", format_tokens(formatopt, source->source));
    printf("toplevel:\n%s\n", format_tokens(formatopt, source->toplevel));
    printf("header:\n%s\n", format_tokens(formatopt, source->header));
}

bool source_write(Source* source, FormatOption formatopt, char* dirname, char* filename) {
    char* s = format_tokens(formatopt, source->source);
    char* t = format_tokens(formatopt, source->toplevel);
    char* h = format_tokens(formatopt, source->header);
    char* include_str = string_concat("#include \"", filename, ".h", "\"\n");
    file_write(string_concat(dirname, "/", filename, ".c"), string_concat(include_str, t, s));
    file_write(string_concat(dirname, "/", filename, ".h"), h);
}
