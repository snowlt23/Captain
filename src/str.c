
#include <string.h>
#include <captain.h>
#include <gc.h>

#if INTERFACE
#include <stdlib.h>
#endif

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

char* string_from_char(char c) {
    char* s = malloc(2);
    s[0] = c;
    s[1] = '\0';
    return s;
}

char* string_copy(char* s) {
    char* newstr = malloc(strlen(s) + 1);
    newstr[strlen(s)] = '\0';
    strcpy(newstr, s);
    return newstr;
}

/*
string_sub("hello", 1, -1) == "ello"
*/
char* string_sub(char* s, int start, int len) {
    if (len < 0) {
        len = strlen(s) - start + (len+1);
    }
    char* newstr = malloc(len + 1);
    newstr[start+len] = '\0';
    memcpy(newstr, s+start, len);
    return newstr;
}

#if INTERFACE
/*
string_concat("a", "b", "c") == "abc"
*/
#define string_concat(...) \
    string_concat_inside( \
        (char*[]){ __VA_ARGS__ }, \
        sizeof((char*[]){ __VA_ARGS__ }) / sizeof(char*) \
    )
#endif

char* string_concat_inside(char** list, size_t len) {
    int newstrlen = 0;
    for (int i = 0; i < len; i++) {
        newstrlen += strlen(list[i]);
    }

    char* newstr = malloc(newstrlen + 1);
    newstr[newstrlen] = '\0';
    int prevlen = 0;
    for (int i = 0; i < len; i++) {
        strcpy(newstr + prevlen, list[i]);
        prevlen += strlen(list[i]);
    }

    return newstr;
}
