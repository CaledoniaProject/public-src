#define _GNU_SOURCE 1
#include <fcntl.h>
#include <getopt.h>
#include <sched.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <linux/limits.h>

void usage()
{
    fprintf(stderr, "Usage: getTCP -p PID\n");
    exit(1);
}

void readFile(char *path)
{
    char buff[256];
    int fd = -1;

    fd = open(path, O_RDONLY);
    if (fd <= 0)
    {
        fprintf(stderr, "Failed to open %s for reading: %s\n", path, strerror(errno));
        return;
    }

    while (1)
    {
        int count = read(fd, buff, sizeof(buff));
        if (count <= 0)
        {
            break;
        }

        write(STDOUT_FILENO, buff, count);
    }

    close(fd);
}

int main(int argc, char **argv) 
{
    char path[PATH_MAX];
    int flag_pid = -1, user_ns = -1, opt = -1;

    while ((opt = getopt(argc, argv, "p:")) != -1)
    {
        switch (opt)
        {
            case 'p':
                flag_pid = atoi(optarg);
                break;
            default:
                usage();
        }
    }

    if (flag_pid <= 0)
    {
        usage();
    }

    snprintf(path, sizeof(path), "/proc/%d/ns/net", flag_pid);
    user_ns = open(path, O_RDONLY);
    if (user_ns <= 0)
    {
        fprintf(stderr, "Failed to open %s for reading: %s\n", path, strerror(errno));
        exit(1);
    }

    if (syscall(308, user_ns, 0) == -1)
    {
       fprintf(stderr, "setns(): %s\n", strerror(errno));
       exit(1); 
    }

    readFile("/proc/net/tcp");
    readFile("/proc/net/tcp6");
    return 0;
}
