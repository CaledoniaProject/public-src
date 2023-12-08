#define __FAVOR_BSD
#include <iostream>
#include <cmath>
#include <cstdio>
#include <unistd.h>
#include <cstring>
#include <cstdlib>
#include <cstring>
#include <sys/un.h>
#include <sys/socket.h>

#define SOCKET_FILE "/tmp/.sock"
#define ERR_QUIT(a) do { perror(a); exit (-1); } while (0);

#define MAXLINE 256
char buf[MAXLINE];

using namespace std;

int main ( int argc , char **argv ) 
{
	int sockfd, opt = 1;
	struct sockaddr_un sock;

	if ((sockfd = socket (PF_UNIX, SOCK_STREAM, 0)) <= 0)
	{
		ERR_QUIT("socket")
	}

	setsockopt (sockfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

	sock.sun_family = AF_UNIX;
	snprintf (sock.sun_path, 108, SOCKET_FILE);

	if (connect (sockfd, (struct sockaddr*)&sock, sizeof(sock)) < 0)
	{
		ERR_QUIT("connect")
	}

	char *msg = strdup ("Fork request\0");
	int len = strlen (msg);
	if (len != write (sockfd, msg, len))
	{
		ERR_QUIT ("write")
	}

	int nbytes = read (sockfd, buf, MAXLINE);
	buf[nbytes] = '\0';

	cout << "Received: " << buf << endl;

	return 0;
}

