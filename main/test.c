
#include <greatest.h>
#include <captain_test.h>

GREATEST_MAIN_DEFS();

int main(int argc, char **argv) {
    GREATEST_MAIN_BEGIN();
    RUN_SUITE(main_suite);
    GREATEST_MAIN_END();
    return 0;
}
