#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <dlfcn.h>

static int (* real_execve)(const char *filename, char *const argv[], char *const envp[]);

int execve(const char *filename, char *const argv[], char *const envp[])
{
	if (real_execve == NULL)
	{
		real_execve = (int (*)(const char *filename, char *const argv[], char *const envp[])) dlsym(RTLD_NEXT, "execve");
	}

	FILE *fp = fopen("/tmp/log.txt", "w+");
	if (fp != NULL)
	{
		fprintf (fp, "cmd=%s\nargv=\n", filename);

		for (size_t i = 0; ; ++ i) 
		{
			if (i == 0)
				continue;

			if (! argv[i])
				break;

			fprintf (fp, "  - %s\n", argv[i]);
		}
	}
	
	return real_execve(filename, argv, envp);
}
