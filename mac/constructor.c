#include <stdio.h>
#include <syslog.h>

__attribute__((constructor)) static void customConstructor(int argc, const char **argv)
{
    puts("Hello from dylib!");
}

