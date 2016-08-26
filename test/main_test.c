
#include <stdio.h>
#include <greatest.h>
#include <captain.h>

TEST hashtable_test() {
    HashTable* table = create_hashtable(40);

    set_hashtable(table, (void*)10, true);
    set_hashtable(table, (void*)11, false);

    GetResult result1 = get_hashtable(table, (void*)10);
    GetResult result2 = get_hashtable(table, (void*)11);
    ASSERT_EQ(true, result1.value);
    ASSERT_EQ(false, result2.value);

    delete_hashtable(table);
}

SUITE(main_suite) {
    RUN_TEST(hashtable_test);
}
