// https://gsec.hitb.org/materials/sg2019/D1%20-%20Infiltrating%20Corporate%20Intranets%20Like%20The%20NSA%20-%20A%20Pre-Auth%20Remote%20Code%20Execution%20on%20Leading%20SSL%20VPNs%20-%20Orange%20Tsai%20&%20Tingyi%20Chan.pdf
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

int main (int argc , char **argv)
{
	if (argc != 2)
	{
		puts("Usage: main 123123");
		puts("       main 123123123123123123123123123123123123123123123123123123123123123123123123");
		return 1;
	}

    char buf[0x40];
    snprintf(buf, 0x40, "/migadmin/lang/%s.json", argv[1]);
    puts(buf);
	return 0;
}

