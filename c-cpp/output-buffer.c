#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

int main (int argc , char **argv)
{
    // 方法1 - 手动 flush stdout
    printf("Buffered, will be flushed");
    fflush(stdout); 

    // 方法2 - 关闭 stdout 缓冲区
    setbuf(stdout, NULL);

    // 方法3 - 写 stderr
    fprintf(stderr, "I will be printed immediately");

	return 0;
}

