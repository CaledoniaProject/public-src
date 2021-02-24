#include <cstring>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define PORT 2020
#define MAXLINE 1024
#define ERR_QUIT(a) do { perror(a); exit (-1); } while (0);

using namespace std;

int main(int argc, char *argv[])
{
	fd_set master;
	fd_set read_fds;
	struct sockaddr_in serveraddr;
	int fdmax;
	int yes = 1;
	int listener = 0;

	FD_ZERO(&master);
	FD_ZERO(&read_fds);

	/* get the listener */
	if ( (listener = socket(AF_INET, SOCK_STREAM, 0) ) == -1)
	{
		ERR_QUIT("socket")
	}

	if ( setsockopt ( listener, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int) ) == -1 )
	{
		ERR_QUIT("setsockopt")
	}

	/* bind */
	serveraddr.sin_family = AF_INET;
	serveraddr.sin_addr.s_addr = INADDR_ANY;
	serveraddr.sin_port = htons(PORT);
	memset(&(serveraddr.sin_zero), '\0', 8);

	if ( bind ( listener, (struct sockaddr *)&serveraddr, sizeof(serveraddr)) == -1)
	{
		ERR_QUIT("bind")
	}

	/* listen */
	if ( listen ( listener, 10 ) == -1 )
	{
		ERR_QUIT("listen")
	}

	/* add the listener to the master set */
	FD_SET(listener, &master);
	/* keep track of the biggest file descriptor */
	fdmax = listener;

	cout << "Listening normally on " << PORT << endl;

	/* loop */
	while (1)
	{
		/* copy it */
		read_fds = master;

		if ( select ( fdmax+1, &read_fds, NULL, NULL, NULL ) == -1 )
		{
			ERR_QUIT("select")
		}

		/*run through the existing connections looking for data to be read*/
		for ( int i = 0; i <= fdmax; ++i )
		{
			struct sockaddr_in clientaddr;
			int newfd = 0;

			if ( FD_ISSET ( i, &read_fds ) )
			{ 
				if ( i == listener )
				{
					/* handle new connections */
					socklen_t addrlen = sizeof(clientaddr);
					if ( ( newfd = accept ( listener, (struct sockaddr *)&clientaddr, &addrlen) ) == -1 )
					{
						ERR_QUIT("accept")
					}
					else
					{
						FD_SET(newfd, &master); /* add to master set */
						if ( newfd > fdmax )
						{ 
							fdmax = newfd;
						}
						cout << argv[0] << ":" << " connection from: " << inet_ntoa ( clientaddr.sin_addr ) << endl;
					}
				}
				else
				{
					char buf[MAXLINE];
					int nbytes = 0;

					/* handle data from a client */
					if ( ( nbytes = recv(i, buf, sizeof(buf), 0) ) <= 0 )
					{
						/* connection closed */
						if ( nbytes == 0 )
						{
							cout << argv[0] << ":" << " socket hung up: " << inet_ntoa ( clientaddr.sin_addr ) << endl;
						}
						else 
						{
							perror("recv");
						}

						close(i);
						FD_CLR(i, &master);
					}
					else
					{
						cout << "Client said: " << buf << endl;

						char msg[] = "Message received\n\0";
						int len = strlen(msg);

						if ( send (i , msg , len , 0) == -1 )
						{
							perror ("send");
						}
						else
						{
							cout << "sent: " << len << " bytes" << endl;
						}
					}
				}
			} /* if FD_ISSET */
		} /* fds loop */
	} /* while loop */
	return 0;
}
