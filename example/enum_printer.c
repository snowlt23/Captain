
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
