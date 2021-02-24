#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define ERR_RET(s) do { perror(s); return 1; } while (0);

int udpsend (const char *hostname, uint16_t port, const char *message)
{
    struct sockaddr_in server;
    struct hostent *hp = NULL;
    int sock = -1;

    if (! (sock = socket (AF_INET, SOCK_DGRAM, 0)))
        ERR_RET("socket");

    if (! (hp = gethostbyname (hostname)))
        ERR_RET("gethostbyname");

    server.sin_family = AF_INET;
    server.sin_port   = htons (port);
    memcpy (&server.sin_addr.s_addr, hp->h_addr, hp->h_length);

    if (sendto (sock, message, strlen(message), 0, (struct sockaddr *)&server, sizeof (server)) < 0)
        ERR_RET("sendto");

    return 0;
}

int main (int argc , char **argv)
{
    if (argc != 4)
    {
        fprintf (stderr, "%s: hostname port message\n", argv[0]);
        exit (1);
    }
    
    udpsend (argv[1], atoi (argv[2]), argv[3]);

    return 0;
}

