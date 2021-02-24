#include <stdio.h>
#include <stdarg.h>

void myprintf (char *fmt, ...)
{
  va_list argp;
  va_start (argp, fmt); 
  vfprintf (stdout, "[INFO]" fmt, argp); 
  va_end (argp);
}

int main (int argc , char **argv)
{
    myprintf ("arg count is %d\n", argc);
	return 0;
}

