#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include <stdio.h>
#define paster( n ) printf( "token" #n " = %d", token##n )
int token9 = 9;

int main()
{
   paster(9);
}


