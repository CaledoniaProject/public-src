#include <sys/socket.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <arpa/inet.h>
#include <unistd.h>

#define ERR_RET(x) do { perror(x); return EXIT_FAILURE; } while (0);
#define BUFFER_SIZE 4095

int  loop (int sock, struct sockaddr_nl *addr)
{
    int     received_bytes = 0;
    struct  nlmsghdr *nlh;
    char    destination_address[32];
    char    gateway_address[32];
    struct  rtmsg *route_entry;  /* This struct represent a route entry \
                                    in the routing table */
    struct  rtattr *route_attribute; /* This struct contain route \
                                            attributes (route type) */
    int     route_attribute_len = 0;
    char    buffer[BUFFER_SIZE];

    bzero(destination_address, sizeof(destination_address));
    bzero(gateway_address, sizeof(gateway_address));
    bzero(buffer, sizeof(buffer));

    /* Receiving netlink socket data */
    while (1)
    {
        received_bytes = recv(sock, buffer, sizeof(buffer), 0);
        if (received_bytes < 0)
            ERR_RET("recv");
        /* cast the received buffer */
        nlh = (struct nlmsghdr *) buffer;
        /* If we received all data ---> break */
        if (nlh->nlmsg_type == NLMSG_DONE)
            break;
        /* We are just intrested in Routing information */
        if (addr->nl_groups == RTMGRP_IPV4_ROUTE)
            break;
    }

    /* Reading netlink socket data */
    /* Loop through all entries */
    /* For more informations on some functions :
     * http://www.kernel.org/doc/man-pages/online/pages/man3/netlink.3.html
     * http://www.kernel.org/doc/man-pages/online/pages/man7/rtnetlink.7.html
     */

    for ( ; NLMSG_OK(nlh, received_bytes); \
                    nlh = NLMSG_NEXT(nlh, received_bytes))
    {
        /* Get the route data */
        route_entry = (struct rtmsg *) NLMSG_DATA(nlh);

        /* We are just intrested in main routing table */
        if (route_entry->rtm_table != RT_TABLE_MAIN)
            continue;

        /* Get attributes of route_entry */
        route_attribute = (struct rtattr *) RTM_RTA(route_entry);

        /* Get the route atttibutes len */
        route_attribute_len = RTM_PAYLOAD(nlh);
        /* Loop through all attributes */
        for ( ; RTA_OK(route_attribute, route_attribute_len); \
            route_attribute = RTA_NEXT(route_attribute, route_attribute_len))
        {
            /* Get the destination address */
            if (route_attribute->rta_type == RTA_DST)
            {
                inet_ntop(AF_INET, RTA_DATA(route_attribute), \
                        destination_address, sizeof(destination_address));
            }
            /* Get the gateway (Next hop) */
            if (route_attribute->rta_type == RTA_GATEWAY)
            {
                inet_ntop(AF_INET, RTA_DATA(route_attribute), \
                        gateway_address, sizeof(gateway_address));
            }
        }

        /* Now we can dump the routing attributes */
        if (nlh->nlmsg_type == RTM_DELROUTE)
            fprintf(stdout, "Deleting route to destination --> %s and gateway %s\n", \
                destination_address, gateway_address);
        if (nlh->nlmsg_type == RTM_NEWROUTE)
            printf("Adding route to destination --> %s and gateway %s\n", \
                            destination_address, gateway_address);
    }

    return 0;
}

int main(int argc, char **argv)
{
    int sock = -1;
    struct sockaddr_nl addr;

    /* Zeroing addr */
    bzero (&addr, sizeof(addr));

    if ((sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE)) < 0)
        ERR_RET("socket");

    addr.nl_family = AF_NETLINK;
    addr.nl_groups = RTMGRP_IPV4_ROUTE;

    if (bind(sock,(struct sockaddr *)&addr,sizeof(addr)) < 0)
        ERR_RET("bind");

    while (1)
        loop (sock, &addr);

    /* Close socket */
    close(sock);

    return 0;
}
