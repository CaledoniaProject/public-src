#include <string.h>

int run(char *src, int len)
{
    char buff[20];
    memcpy(buff, src, len);
    return buff[10] == 'a';
}

int main(int argc, char **argv)
{
    run(argv[1], strlen(argv[1]));
    return 0;
}

