
#include <stdio.h>
#include <captain.h>
#include <gc.h>

#define malloc GC_malloc
#define realloc GC_realloc
#define calloc(m, n) GC_malloc((m)*(n))
#define free

#define FILE_STRING_INTERVAL 512

char* file_read(char* filename) {
    FILE* fp = fopen(filename, "r");
    if (fp == NULL) {
        return NULL;
    }
    char* s = malloc(FILE_STRING_INTERVAL);
    int inteval_num = 1;
    int len = 0;
    char c;
    while ((c = fgetc(fp)) != EOF) {
        s[len] = c;
        len++;
        if (FILE_STRING_INTERVAL*inteval_num <= len) {
            inteval_num++;
        }
    }
    return s;
}
