// 删除FS缓存: POSIX_FADV_DONTNEED
// 可能需要执行多次才会有效
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

int main(int argc, char **argv)
{
	char *filename = NULL;

	if (argc != 2)
	{
		fprintf(stderr, "Usage: fadvise filename\n");
		return -1;
	}

	filename = argv[1];

	int fd = open(filename, O_RDONLY);
	if (fd < 0)
	{
		fprintf(stderr, "open() on %s: %s\n", filename, strerror(errno));
		return -1;
	}

	if (posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) != 0)
	{
		fprintf(stderr, "fadvise() on %s: %s\n", filename, strerror(errno));
		close(fd);
		return -1;
	}

	close(fd);
	return 0;
}