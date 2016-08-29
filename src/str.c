
#include <string.h>
#include <captain.h>
#include <gc.h>

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

/*
string_sub("hello", 1, -1) == "ello"
*/
char* string_sub(char* s, int start, int len) {
    char* newstr = malloc(start + len + 1);
    newstr[start+len] = '\0';
    if (len < 0) {
        len = strlen(s) - start + (len+1);
    }
    memcpy(newstr, s+start, len);
    return newstr;
}

#if INTERFACE
/*
string_concat("a", "b", "c") == "abc"
*/
#define string_concat(...) \
    string_concat_inside( \
        (char*){ __VA_ARGS__ }, \
        sizeof((char*){ __VA_ARGS__ }) / sizeof(char*) \
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
