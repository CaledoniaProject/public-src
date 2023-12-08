// 获取 arp -a 的结果

#include <stdio.h>
#include <winsock2.h>
#include <iphlpapi.h>
#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "Ws2_32.lib")

int main(int argc, char **argv)
{
    PMIB_IPNETTABLE pIpNetTable = NULL;
    DWORD dwSize = 0;

    GetIpNetTable(NULL, &dwSize, 0);
    pIpNetTable = (MIB_IPNETTABLE *) malloc (dwSize);

    if (! pIpNetTable)
    {
        fprintf(stderr, "Unable to allocate %d bytes: error code %d\n", dwSize, GetLastError());
        return 1;
    }

    if (GetIpNetTable (pIpNetTable, &dwSize, 0) == NO_ERROR)
    {
        for (int i = 0; i < pIpNetTable->dwNumEntries; i ++)
        {
            printf ("Address: %s\n", inet_ntoa(*(struct in_addr *)&pIpNetTable->table[i].dwAddr));
            printf("Phys Address: %.2x:%.2x:%.2x:%.2x:%.2x:%.2x\n",
                pIpNetTable->table[i].bPhysAddr[0],
                pIpNetTable->table[i].bPhysAddr[1],
                pIpNetTable->table[i].bPhysAddr[2],
                pIpNetTable->table[i].bPhysAddr[3],
                pIpNetTable->table[i].bPhysAddr[4],
                pIpNetTable->table[i].bPhysAddr[5]);

            printf("Index:  %ld\n", pIpNetTable->table[i].dwIndex);
            printf("Type:   %ld\n", pIpNetTable->table[i].dwType);
            printf("\n");
        }

        free (pIpNetTable);
    }
    else
    {
        fprintf(stderr, "GetIpNetTable() error: %d\n", GetLastError());
    }

    return 0;
}
