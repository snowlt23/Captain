
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <captain.h>

#define GC_HASHTABLE_SIZE 256

#if INTERFACE
#include <stdint.h>
#endif

static void** stack_start;
static HashTable* mallocs;

void gc_init(int *pargc) {
    stack_start = (void**)(pargc);
    mallocs = create_hashtable(GC_HASHTABLE_SIZE);
}

void* gc_malloc(size_t size) {
    void* ret = malloc(size);
    set_hashtable(mallocs, ret, true);
    return ret;
}

void malloc_reset(HashTable* table, List* list, GetResult result) {
    list->value = false;
}

void gc_sweep(HashTable* table, List* list, GetResult result) {
    if (list->value == false) {
        free(list->key);
        erase_hashtable(table, result);
    }
}

void gc_collect() {
    void *end;
    hashtable_for(mallocs, &malloc_reset);
    for (void** p = stack_start; p > &end; p--) {
        GetResult result = get_hashtable(mallocs, *p);
        if (result.type == SUCCESS) {
            set_hashtable(mallocs, *p, true);
        }
    }
    hashtable_for(mallocs, &gc_sweep);
}
