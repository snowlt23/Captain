
#if INTERFACE

#define array_push_single(arr, length, type, data) \
    arr = realloc(arr, sizeof(type) * (length + 1)); \
    arr[length] = data; \
    length++

#define array_push(arr, length, type, data) \
    arr = realloc(arr, sizeof(type) * (length + 1)); \
    arr[length] = data

#define array_push_finish(length) \
    length++

#endif
