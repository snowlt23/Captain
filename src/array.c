
#if INTERFACE

#define array_push(arr, length, type, data) \
    arr = realloc(arr, sizeof(type) * (length + 1)); \
    arr[length] = data; \
    length++

#endif
