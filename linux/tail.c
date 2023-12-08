#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#define BUFSIZE 512

int main (int argc , char **argv)
{
    int lines = 0;
    FILE *fp;
    char buf[BUFSIZE];

	int _line_cnt = 0, _offset = 0, pos = 0;

	if (argc == 3)
	{
		lines = atoi (argv[1] + 1);
		if (lines == 0)
		{
			fprintf(stderr, "usage: %s -10 file_name\n", argv[0]);
		}

		if (NULL == (fp = fopen (argv[argc - 1], "r")))
		{
			perror("fopen");
		}
	}

	if (fp == NULL || lines == 0)
	{
		return 1;
	}

	++ lines;

    while (1)
    {
		// not enough contents to read
        if (fseek (fp, pos - BUFSIZE, SEEK_END) == 0)
        {
        	pos -= BUFSIZE;
        }
		
		int rd = fread (buf, sizeof (char), BUFSIZE, fp), i = rd;

		for (; i >= 0 && _line_cnt != lines ; --i)
		{
			if (buf[i] == '\n')
			{
				++ _line_cnt;
			}
		}

		// if seek was unsuccessful, no impact
		_offset = (pos + i);

		if (rd < BUFSIZE || _line_cnt == lines)
			break;
	}

	// not enough lines
	if (lines > _line_cnt)
		rewind (fp);
	// otherwise use saved offset
	else
		fseek (fp, _offset + 2, SEEK_END);

	while (NULL != fgets (buf, BUFSIZE, fp))
		printf (buf);

	return 0;
}

