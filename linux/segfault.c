#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <signal.h>

void handler (int sig) {
    puts ("Unsuccessful exploit: program caught segfault, exiting in silence.");
    exit (0);
} 

int main (int argc , char **argv)
{
    signal (SIGSEGV, handler);
    return 0;
}
