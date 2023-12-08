// gcc -dynamiclib lib.c -o lib.dylib
#include <stdio.h>
#include <syslog.h>

__attribute__((constructor))
static void customConstructor(int argc, const char **argv)
 {
     printf("Hello from dylib!\n");
     syslog(LOG_ERR, "Dylib injection successful in %s\n", argv[0]);
}

