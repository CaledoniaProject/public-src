#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

int main (int argc , char **argv)
{
    struct A 
    {
        int a;
        int b;
    };

    struct B : A 
    {
        int c;
    };

    B b;
    b.a = 1;
    b.b = 2;
    b.c = 3;

    char *p = (char *)&b;
    for (int i = 0; i < sizeof(B); i ++)
    {
        printf("%02X ", *(p + i) & 0xFF);
    }
	return 0;
}

