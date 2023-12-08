#include <windows.h>
#include <winevt.h>
#include <stdio.h>

#pragma comment(lib, "wevtapi.lib")

int wmain (int argc, wchar_t* argv[])
{
    if (argc != 2)
    {
        printf("Usage: %s [Security | Application | System | ...]\n", argv[0]);
        exit(1);
    }

    DWORD status = EvtClearLog(NULL, argv[1], NULL, NULL);
    if (status != TRUE)
    {
        printf("EvtClearLog failed with error code: %d\n", status);
    }
    else
    {
        printf("Success\n");
    }

	return 0;
}

