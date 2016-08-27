
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
    int list_index;
    int link_index;
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
        List* list = table->lists[index];
        int link_index = 0;
        for (;;) {
            if (list->key = key) {
                GetResult result;
                result.type = SUCCESS;
                result.value = list->value;
                result.list_index = index;
                result.link_index = link_index;
                return result;
            } else if (list->next == NULL) {
                GetResult result;
                result.type = FAILURE;
                return result;
            } else {
                list = list->next;
                link_index++;
            }
        }
    }
}

void erase_hashtable(HashTable* table, GetResult result) {
    List* list = table->lists[result.list_index];
    List* prev_list = NULL;
    for (int i = 0; i < result.link_index; i++) {
        prev_list = list;
        list = list->next;
    }
    if (prev_list == NULL) {
        List* next = list->next;
        list->next = NULL;
        delete_list(list);
        if (next == NULL) {
            table->lists[result.list_index] = NULL;
        } else {
            table->lists[result.list_index] = next;
        }
    } else {
        List* next = list->next;
        list->next = NULL;
        delete_list(list);
        if (next == NULL) {
            prev_list->next = NULL;
        } else {
            prev_list->next = next;
        }
    }
}

void hashtable_for(HashTable* table, void (*f)(HashTable*, List*, GetResult)) {
    for (int i = 0; i < table->tablesize; i++) {
        if (table->lists[i] == NULL) {
            continue;
        } else {
            List* list = table->lists[i];
            int link_index = 0;
            for (;;) {
                GetResult result;
                result.type = SUCCESS;
                result.value = list->value;
                result.list_index = i;
                result.link_index = link_index;
                f(table, list, result);
                if (list->next == NULL) {
                    break;
                } else {
                    list = list->next;
                    link_index++;
                }
            }
        }
    }
}
