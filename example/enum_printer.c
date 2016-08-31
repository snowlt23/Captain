
#include <stdio.h>

@printable
enum ActorType {
    ActorStatic,
    ActorMovable,
    ActorLight,
    ActorDummy,
};

int main() {
    enum ActorType at = ActorMovable;
    ActorType(print)(at);
}

// variadic char* string_concat(cha** list, int len) {
//
// }
