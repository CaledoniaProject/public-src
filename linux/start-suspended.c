#include <sys/ptrace.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
    
void child(int argc, char **argv)
{
    ptrace(PTRACE_TRACEME, 0, 0, 0);
    setsid();
    execv("/bin/sleep", argv);
}

void parent(pid_t pid)
{
    int	status;
    waitpid(pid, &status, 0);

    if (WIFSTOPPED(status) && WSTOPSIG(status) == SIGTRAP) {
        puts("Resuming child");
        ptrace(PTRACE_CONT, pid, (caddr_t)1, 0);
    }
}

int
main(int argc, char **argv)
{
    pid_t result;

    result = fork();
    switch (result) {
    case 0:
        child(argc, argv);
        break;
    case -1:
        break;
    default:
        parent(result);
        break;
    }
}

