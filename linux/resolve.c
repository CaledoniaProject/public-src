#include<stdio.h> 
#include<string.h> 
#include<stdlib.h> 
#include<sys/socket.h>
#include<errno.h> 
#include<netdb.h>	
#include<arpa/inet.h>

int host2ip (char * hostname, char *ip);

int main(int argc , char *argv[])
{
    char ip[20] = { 0 };

    if (argc < 2)
    {
        puts ("Usage: resolve hostname");
        exit(1);
    }

    if (host2ip (argv[1], ip))
        puts ("error");
    else
        printf ("%s resolved to %s\n", argv[1], ip);

    return 0;
}

int host2ip (char * hostname, char* ip)
{
    struct hostent *he;
    struct in_addr **addr_list;

    if ( !(he = gethostbyname(hostname)) )
    {
        herror("gethostbyname");
        return 1;
    }

    addr_list = (struct in_addr **) he->h_addr_list;

    for (int i = 0; addr_list[i] != NULL; i++)
    {
        strcpy(ip , inet_ntoa(*addr_list[i]) );
        return 0;
    }

    return 1;
}
