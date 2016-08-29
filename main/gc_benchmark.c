
#include <stdio.h>
#include <captain.h>

void walk(HashTable* table, List* list) {
    printf("Walk!!\n");
}

int main(int argc, char const *argv[]) {
    gc_init(&argc);
    for (int i = 0; i < 100000; i++) {
        void* a = gc_malloc(10);
        void* b = gc_malloc(10);
        // a = gc_realloc(a, 20);
        // a = NULL;
    }
    gc_collect();
    // for (int i = 0; i < 10; i++) {
    //     void* a = gc_malloc(10);
    //     a = gc_realloc(a, 20);
    // }
    // gc_collect();

    // HashTable* table = create_hashtable(256);
    //
    // HeapInfo hi = { 0, 0, true };
    // set_hashtable(table, (void*)10, hi);
    // set_hashtable(table, (void*)(256+10), hi);
    // set_hashtable(table, (void*)(256*2+10), hi);
    // set_hashtable(table, (void*)(256*3+10), hi);
    // set_hashtable(table, (void*)(256*4+10), hi);
    // set_hashtable(table, (void*)(256*5+10), hi);
    //
    // printf("1\n");
    // hashtable_for(table, &walk);
    //
    // erase_hashtable(table, get_hashtable(table, (void*)10));
    // erase_hashtable(table, get_hashtable(table, (void*)(256+10)));
    // erase_hashtable(table, get_hashtable(table, (void*)(256*2+10)));
    // erase_hashtable(table, get_hashtable(table, (void*)(256*3+10)));
    //
    // printf("0\n");
    // hashtable_for(table, &walk);

    return 0;
}
