
#include <stdint.h>
#include <stdlib.h>
#include <captain.h>

#if INTERFACE

#include <stdbool.h>

typedef struct _tagList {
    void* key;
    bool value;
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
    bool value;
} GetResult;

#endif

List* create_list(void* key, bool value) {
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

void set_hashtable(HashTable* table, void* key, bool value) {
    uintptr_t index = calc_hash(table, key);
    if (table->lists[index] == NULL) {
        table->lists[index] = create_list(key, value);
    } else {
        List* list = table->lists[index];
        if (list->key = key) {
            list->value = value;
        } else if (list->next == NULL) {
            list->next = create_list(key, value);
        } else {
            list = list->next;
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
        List* list = table->lists[index];
        if (list->key = key) {
            GetResult result;
            result.type = SUCCESS;
            result.value = list->value;
            return result;
        } else if (list->next == NULL) {
            GetResult result;
            result.type = FAILURE;
            return result;
        } else {
            list = list->next;
        }
    }
}
