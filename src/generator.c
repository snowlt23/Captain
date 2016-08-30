
#include <string.h>
#include <captain.h>

bool expect_token(Token token, char* s) {
    if (strcmp(token.text, s) == 0) {
        return true;
    } else {
        return false;
    }
}
