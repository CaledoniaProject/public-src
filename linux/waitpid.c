#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

int main() 
{
    int pid;
    int status;

    pid = fork();
    if (pid == 0) 
    {
        printf("child pid: %d\n", getpid());
        while (1)
        {
            sleep(1000);
        }

        return 0;
    }
    else if (pid < 0)
    {
        perror("fork()");
        return -1;
    }

    waitpid(pid, &status, 0);
    printf("exit code = %d, signaled = %d\n", status, WIFSIGNALED(status));

    return 0;
}
