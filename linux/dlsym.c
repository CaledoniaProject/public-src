#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <dlfcn.h>

int main ( int argc , char **argv )
{
    void *mylib = dlopen ("./shared.so", RTLD_LAZY);
    void (*say)(const char *) = dlsym (mylib, "say");
    say ("Cool");
    return 0;
}

