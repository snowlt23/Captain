
#include <stdio.h>
#include <captain.h>

int main(int argc, char const *argv[]) {
    gc_init(&argc);
    for (;;) {
        void* a = gc_malloc(10000);
        a = NULL;
        gc_collect();
    }
    return 0;
}
