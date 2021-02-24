#define _GNU_SOURCE

#include <fcntl.h>
#include <stdio.h>
#include <stdio.h>
#include <unistd.h>
#include <err.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>

int main(int argc, char* argv[])
{
    int fd = memfd_create("script", 0);
    if (fd == -1)
        err(1, "%s failed", "memfd_create");

    char buff[256];
    int fd_read = open("/bin/sleep", O_RDONLY);
    while (1)
    {
        int count = read(fd_read, buff, sizeof(buff));
        if (count <= 0)
        {
            close(fd_read);
            break;
        }

        write(fd, buff, count);
    }

    {
        const char * const argv[] = {"script", "999", NULL};
        const char * const envp[] = {NULL};
        fexecve(fd, (char * const *) argv, (char * const *) envp);
    }

    err(1, "%s failed", "fexecve");
    return 0;
}
