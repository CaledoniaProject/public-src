#include <string.h>
#define _XOPEN_SOURCE
#define _GNU_SOURCE_
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <pty.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <sys/select.h>
#include <sys/fcntl.h>
#include <termios.h>
#include <netdb.h>
#include <unistd.h>
#include <linux/tcp.h>
#define ERR_QUIT(a) do { perror(a); exit (1); } while (0);

struct termios saved;

int set_nonblock(int fd)
{
	int val;

	val = fcntl(fd, F_GETFL, 0);
	if (val < 0)
		ERR_QUIT("fcntl GETFL");

	val |= O_NONBLOCK;
	if (fcntl(fd, F_SETFL, val) == -1)
		ERR_QUIT("fcntl SETFL");
	return 0;
}

void enter_raw_mode()
{
	struct termios tio;

	if (tcgetattr(fileno(stdin), &tio) == -1)
		ERR_QUIT("tcgetattr");

	tio.c_iflag |= IGNPAR;
	tio.c_iflag &= ~(ISTRIP | INLCR | IGNCR | ICRNL | IXON | IXANY | IXOFF);
#ifdef IUCLC
	tio.c_iflag &= ~IUCLC;
#endif
	tio.c_lflag &= ~(ISIG | ICANON | ECHO | ECHOE | ECHOK | ECHONL);
#ifdef IEXTEN
	tio.c_lflag &= ~IEXTEN;
#endif
	tio.c_oflag &= ~OPOST;
	tio.c_cc[VMIN] = 1;
	tio.c_cc[VTIME] = 0;

	if (tcsetattr(fileno(stdin), TCSADRAIN, &tio))
		ERR_QUIT("tcsetattr");
}

int main()
{
	enter_raw_mode();
	return execl("/bin/nc.traditional", "/bin/nc.traditional", "-l", "-p", "9999", NULL);
}
