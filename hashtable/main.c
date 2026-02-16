#include<stdio.h>

extern void* new_hashtable(long c);
extern int* query_hashtable(void *, char*);
extern void hashtable_insert(void *, char*, int);


int main() {
    printf("Hello, world!\n");

    void* table = new_hashtable(10);
    // void* value = query_hashtable(table, "A");

    // // // print ptr
    // printf("%p\n", value);

    hashtable_insert(table, "A", 42);
    hashtable_insert(table, "B", 43);

    int* value = query_hashtable(table, "A");
    printf("%d\n", *value);
    
    value = query_hashtable(table, "B");
    printf("%d\n", *value);

    value = query_hashtable(table, "C");
    printf("%p\n", value);

    return 0;
}