
int a = 1;

// add(1, 2.0)

/*
    Hello!!
*/

class Actor

@test
void assert_test() {
    ASSERT_EQ(a, b);
}

int add(const int* a, const int* b) {
    return *a + *b;
}

int main() {
    int a = 1;
    int b = 2.0;
    a += add(1, 2 + (1 - 1));
    if (a > b) {
        printf("%d\n", a);
    }
    return 0;
}

generate_test();
