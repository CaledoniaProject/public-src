/*  
 *  iptables rules counting tool
 *
 *  Compile with:
 *  gcc -I include/ -I ../include/ ipt-count.c -liptc -lip4tc -lxtables -o ipt
 *
 *  Run with:
 *  sudo ./ipt
 *  sudo ./ipt filter
 *
 * */

#include <getopt.h>
#include <sys/errno.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <netdb.h>
#include <libiptc/libiptc.h>

/* Debugging prototype. */
static int for_each_table (int (*func)(const char *tablename))
{
	int err = 1;
	FILE *procfile = NULL;
	char tablename[255];

	procfile = fopen("/proc/net/ip_tables_names", "re");
	if (!procfile)
		return 0;

	while (fgets(tablename, sizeof(tablename), procfile)) {
		if (tablename[strlen(tablename) - 1] != '\n')
            continue;
		tablename[strlen(tablename) - 1] = '\0';
		err += func(tablename);
	}

	fclose(procfile);
	return err;
}

const char *default_policy (struct xtc_handle *handle)
{
    struct xt_counters counters;
    return iptc_get_policy ("INPUT", &counters, handle);
}

static int do_output (const char *tablename)
{
	struct xtc_handle *h  = NULL;
	const char *chain     = NULL;
    int count             = 0;

	if (!tablename)
		return for_each_table(&do_output);

	h = iptc_init(tablename);
	if (!h)
    {
        puts ("Error initializing iptc!");
        return 1;
    }

	for (chain = iptc_first_chain(h);
	     chain;
	     chain = iptc_next_chain(h)) {
		const struct ipt_entry *e;
		e = iptc_first_rule(chain, h);
		while(e) {
            ++ count;
			e = iptc_next_rule(e, h);
		}
	}

	printf ("%s: policy %s, %d rules in total.\n", tablename, default_policy (h), count);

    return 0;
}

int main(int argc, char *argv[])
{
    do_output (argc == 2 ? argv[1] : NULL);
    return 0;
}
