
#include <stdint.h>
#include <stdlib.h>
#include <captain.h>

#if INTERFACE

#include <stdbool.h>

typedef struct {
    size_t size;
    bool marked;
    bool scan;
} HeapInfo;

typedef struct _tagList {
    void* key;
    HeapInfo value;
    struct _tagList* next;
} List;

typedef struct {
    List** lists;
    int tablesize;
} HashTable;

typedef enum {
    SUCCESS,
    FAILURE,
} ResultType;

typedef struct {
    ResultType type;
    HeapInfo value;
    List* prev_list;
    List* current_list;
    int index;
} GetResult;

#endif

List* create_list(void* key, HeapInfo value) {
    List* list = malloc(sizeof(List));
    list->key = key;
    list->value = value;
    list->next = NULL;
    return list;
}

void delete_list(List* list) {
    if (list->next != NULL) {
        delete_list(list->next);
    }
    free(list);
}

void delete_single_list(List* list) {
    free(list);
}

HashTable* create_hashtable(int tablesize) {
    HashTable* table = malloc(sizeof(HashTable));
    table->lists = malloc(sizeof(List*) * tablesize);
    for (int i = 0; i < tablesize; i++) {
        table->lists[i] = NULL;
    }
    table->tablesize = tablesize;
    return table;
}

void delete_hashtable(HashTable* table) {
    for (int i = 0; i < table->tablesize; i++) {
        if (table->lists[i] != NULL) {
            delete_list(table->lists[i]);
        }
    }
    free(table->lists);
    free(table);
}

uintptr_t calc_hash(HashTable* table, void* key) {
    return (uintptr_t)key % (uintptr_t)table->tablesize;
}

void set_hashtable(HashTable* table, void* key, HeapInfo value) {
    uintptr_t index = calc_hash(table, key);
    if (table->lists[index] == NULL) {
        table->lists[index] = create_list(key, value);
    } else {
        List* list = table->lists[index];
        for (;;) {
            if (list->key == key) {
                list->value = value;
                break;
            } else if (list->next == NULL) {
                list->next = create_list(key, value);
                break;
            } else {
                list = list->next;
            }
        }
    }
}

GetResult get_hashtable(HashTable* table, void* key) {
    uintptr_t index = calc_hash(table, key);
    if (table->lists[index] == NULL) {
        GetResult result;
        result.type = FAILURE;
        return result;
    } else {
        List* prev = NULL;
        List* list = table->lists[index];
        for (;;) {
            if (list->key = key) {
                GetResult result;
                result.type = SUCCESS;
                result.value = list->value;
                result.prev_list = prev;
                result.current_list = list;
                result.index = index;
                return result;
            } else if (list->next == NULL) {
                GetResult result;
                result.type = FAILURE;
                return result;
            } else {
                prev = list;
                list = list->next;
            }
        }
    }
}

void erase_hashtable(HashTable* table, GetResult result) {
    List* list = result.current_list;
    List* next = list->next;
    delete_single_list(list);
    if (result.prev_list == NULL) {
        table->lists[result.index] = next;
    } else {
        result.prev_list->next = next;
    }
}

void hashtable_for(HashTable* table, void (*f)(HashTable*, List*, GetResult)) {
    for (int i = 0; i < table->tablesize; i++) {
        if (table->lists[i] == NULL) {
            continue;
        } else {
            List* prev = NULL;
            List* list = table->lists[i];
            for (;;) {
                GetResult result;
                result.type = SUCCESS;
                result.value = list->value;
                result.prev_list = prev;
                result.current_list = list;
                result.index = i;
                f(table, list, result);
                List* next = list->next;
                if (next == NULL) {
                    break;
                } else {
                    prev = list;
                    list = next;
                }
            }
        }
    }
}
