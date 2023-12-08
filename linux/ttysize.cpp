#include <iostream>
#include <cstring>
#include <sys/ioctl.h>

using namespace std;

void output_middle (const char *s, int term_cols)
{
	cout << string ( (term_cols - strlen(s)) >> 1, ' ') << s << endl;
}

int main ( int argc , char **argv ) 
{
	struct winsize w;
	ioctl(0, TIOCGWINSZ, &w);

	output_middle ("some string", w.ws_col);
	return 0;
}

