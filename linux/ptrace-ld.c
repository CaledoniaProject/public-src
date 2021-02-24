#include <stdlib.h>
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <signal.h>
#include <sys/ptrace.h>

int main(int argc, char **argv) {
    void *handle;
    long (*go)(enum __ptrace_request request, pid_t pid);
    char haha[] = "ptrace";

    // get a handle to the library that contains 'ptrace'
    handle = dlopen ("libc.so", RTLD_LAZY);

    // reference to the dynamically-resolved function 'ptrace'
    go = dlsym(handle, haha);

    if (go(PTRACE_TRACEME, 0) < 0) {
        puts("being traced");
	    exit(1);
    }

    puts("not being traced");

    // cleanup
    // dlclose(handle);

    return 0;
}
