
#include <stdio.h>
#include <greatest.h>
#include <captain.h>

// TEST hashtable_test() {
//     HashTable* table = create_hashtable(40);
//
//     set_hashtable(table, (void*)10, true);
//     set_hashtable(table, (void*)11, false);
//
//     GetResult result1 = get_hashtable(table, (void*)10);
//     GetResult result2 = get_hashtable(table, (void*)11);
//     ASSERT_EQ(true, result1.value);
//     ASSERT_EQ(false, result2.value);
//
//     delete_hashtable(table);
// }

// TEST gc_test() {
//     int start;
//     gc_init(&start);
//     void* a = gc_malloc(10);
//     void* b = gc_malloc(10);
//     a = realloc(a, 20);
//     a = NULL;
//     gc_collect();
// }

TEST tokenizer_test() {
    char* source = "int main() { printf(\"%d\n\", 1); }";
    Tokens* tokens = parse_string(source);
    tokens_print(tokens);
}

SUITE(main_suite) {
    // RUN_TEST(hashtable_test);
    // RUN_TEST(gc_test);
    RUN_TEST(tokenizer_test);
}
