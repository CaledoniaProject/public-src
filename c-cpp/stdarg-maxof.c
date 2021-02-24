#include <stdio.h>
#include <stdarg.h>

int maxof(int n_args, ...)
{
    va_list ap;
    va_start(ap, n_args);
    int max = va_arg(ap, int);
    for(int i = 2; i <= n_args; i++) {
        int a = va_arg(ap, int);
        if(a > max) max = a;
    }
    va_end(ap);
    return max;
}

int main (int argc , char **argv)
{
    printf ("%d\n", maxof(3, 1, 2, 10));   
	return 0;
}

