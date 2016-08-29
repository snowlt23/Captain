
#include <stdlib.h>
#include <stdio.h>
#include <captain.h>

#ifndef GC_HASHTABLE_SIZE
    #define GC_HASHTABLE_SIZE 256
#endif
#ifndef GC_COLLECT_THRESHOLD
    #define GC_COLLECT_THRESHOLD 1024*1024
#endif
#ifndef GC_ALLOCATOR
    #define GC_ALLOCATOR malloc
#endif
#ifndef GC_REALLOCATOR
    #define GC_REALLOCATOR realloc
#endif
#ifndef GC_DEALLOCATOR
    #define GC_DEALLOCATOR free
#endif

#if INTERFACE
#include <stdint.h>
#include <stdbool.h>
#endif

static void** stack_start;
static HashTable* mallocs;
static size_t allocated_size;

void gc_init(int *pargc) {
    stack_start = (void**)(pargc);
    mallocs = create_hashtable(GC_HASHTABLE_SIZE);
    allocated_size = 0;
}

void gc_threshold() {
    printf("%d\n", allocated_size);
    if (allocated_size > GC_COLLECT_THRESHOLD) {
        gc_collect();
    }
}

void* gc_malloc_inside(size_t size, bool scan) {
    void* ret = GC_ALLOCATOR(size);
    if (ret == NULL) {
        return NULL;
    }

    HeapInfo hi = { size, true, scan };
    set_hashtable(mallocs, ret, hi);
    allocated_size += size;

    gc_threshold();

    return ret;
}

void* gc_malloc(size_t size) {
    return gc_malloc_inside(size, true);
}

void* gc_malloc_unscan(size_t size) {
    return gc_malloc_inside(size, false);
}

void* gc_realloc_inside(void* ptr, size_t size, bool scan) {
    void* ret = GC_REALLOCATOR(ptr, size);
    if (ret == NULL) {
        return NULL;
    }

    GetResult result = get_hashtable(mallocs, ptr);
    if (result.type == SUCCESS) {
        allocated_size -= result.value.size;
        erase_hashtable(mallocs, result);
    }

    HeapInfo hi = { size, true, scan };
    set_hashtable(mallocs, ret, hi);
    allocated_size += size;

    gc_threshold();

    return ret;
}

void* gc_realloc(void* ptr, size_t size) {
    return gc_realloc_inside(ptr, size, true);
}

void* gc_realloc_unscan(void* ptr, size_t size) {
    return gc_realloc_inside(ptr, size, false);
}

void gc_malloc_reset(HashTable* table, List* list, GetResult result) {
    list->value.marked = false;
}

void gc_mark(void** start, void** end) {
    for (void** p = start; p > end; p--) {
        GetResult result = get_hashtable(mallocs, *p);
        if (result.type == SUCCESS && result.value.marked == false) {
            HeapInfo marked_hi = result.value;
            marked_hi.marked = true;
            set_hashtable(mallocs, *p, marked_hi);
            if (result.value.scan) {
                void** pp = (void**)*p;
                gc_mark(pp, pp + result.value.size);
            }
        }
    }
}

void gc_sweep() {
    for (int i = 0; i < mallocs->tablesize; i++) {
        if (mallocs->lists[i] == NULL) {
            continue;
        } else {
            List* prev = NULL;
            List* list = mallocs->lists[i];
            for (;;) {
                List* next = list->next;
                if (list->value.marked == false) {
                    GC_DEALLOCATOR(list->key);
                    allocated_size -= list->value.size;
                    delete_single_list(list);
                    if (prev == NULL) {
                        mallocs->lists[i] = next;
                    } else {
                        prev->next = next;
                    }
                } else {
                    prev = list;
                }
                if (next == NULL) {
                    break;
                }
                list = next;
            }
        }
    }
}

void gc_collect() {
    void *end;
    hashtable_for(mallocs, &gc_malloc_reset);
    gc_mark(stack_start, &end);
    gc_sweep();
}
