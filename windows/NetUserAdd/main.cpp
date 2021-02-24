#include <stdio.h>
#include <windows.h> 
#include <lm.h>
#pragma comment(lib, "netapi32.lib")

void PRINT_ERR(const WCHAR *name)
{
    wchar_t errstr[256];
    FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError(), 
              MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT), errstr, 256, NULL);

    wprintf (L"%s: %d: %s", name, GetLastError(), errstr);
}

int wmain(int argc, wchar_t *argv[])
{
    if (argc != 3)
    {
        puts("Usage: NetUserAdd ASPNET ASP.NET12345");
        exit (1);
    }    
   
    NET_API_STATUS nStatus = 0;
    
    USER_INFO_1 ui;
    ui.usri1_name        = argv[1];
    ui.usri1_password    = argv[2];
    ui.usri1_priv        = USER_PRIV_USER;
    ui.usri1_home_dir    = NULL;
    ui.usri1_comment     = NULL;
    ui.usri1_flags       = UF_SCRIPT;
    ui.usri1_script_path = NULL;

    nStatus = NetUserAdd(NULL, 1, (LPBYTE)&ui, NULL);

    if (nStatus != NERR_Success)
    {
        if (nStatus == NERR_UserExists)
        {
            wprintf(L"User %s already exists\n", ui.usri1_name);
            exit (1);
        }
        else
        {
            wprintf(L"NetUserAdd error: %d\n", nStatus);
            exit (1);   
        }
    }

    LOCALGROUP_MEMBERS_INFO_3 lgmi3;
    lgmi3.lgrmi3_domainandname = ui.usri1_name;

    nStatus = NetLocalGroupAddMembers(NULL, L"Administrators", 3, (LPBYTE)&lgmi3, 1);

    if (nStatus != NERR_Success && nStatus != ERROR_MEMBER_IN_ALIAS)
    {
        fprintf(stderr, "NetLocalGroupAddMembers error: %d\n", nStatus);
        exit (1);
    }

    wprintf (L"Added %s with password %s", ui.usri1_name, ui.usri1_password);
    return 0;
}

