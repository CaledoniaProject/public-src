#include <windows.h>
#include <stdio.h>
#pragma comment(lib, "Advapi32.lib")

void PRINT_ERR(const WCHAR *name)
{
	wchar_t errstr[256];
	FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError(), 
              MAKELANGID(LANG_ENGLISH, SUBLANG_DEFAULT), errstr, 256, NULL);

	wprintf (L"%s: %d: %s", name, GetLastError(), errstr);
}

BOOL SetPrivilege(
    HANDLE hToken,          // access token handle
    LPCTSTR lpszPrivilege,  // name of privilege to enable/disable
    BOOL bEnablePrivilege   // to enable or disable privilege
    ) 
{
    TOKEN_PRIVILEGES tp;
    LUID luid;

    if ( !LookupPrivilegeValue( 
            NULL,            // lookup privilege on local system
            lpszPrivilege,   // privilege to lookup 
            &luid ) )        // receives LUID of privilege
    {
		PRINT_ERR(L"LookupPrivilegeValue");
        return FALSE; 
    }

    tp.PrivilegeCount = 1;
    tp.Privileges[0].Luid = luid;
    if (bEnablePrivilege)
        tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    else
        tp.Privileges[0].Attributes = 0;

    // Enable the privilege or disable all privileges.

    if ( !AdjustTokenPrivileges(
           hToken, 
           FALSE, 
           &tp, 
           sizeof(TOKEN_PRIVILEGES), 
           (PTOKEN_PRIVILEGES) NULL, 
           (PDWORD) NULL) )
    { 
		PRINT_ERR(L"AdjustTokenPrivileges");
        return FALSE; 
    } 

    if (GetLastError() == ERROR_NOT_ALL_ASSIGNED)
    {
        printf ("The token does not have the specified privilege.\n");
        return FALSE;
    } 

    return TRUE;
}

int runas(const WCHAR *domain, const WCHAR *user, const WCHAR *pass, WCHAR *cmd)
{
	HANDLE token, token2;
	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	int result = 0;

	wprintf (
		L"Domain: %s\n"
		L"User:   %s\n"
		L"Pass:   %s\n"
		L"Cmd:    %s\n\n", 
		domain, user, pass, cmd);

	if (LogonUser(user, domain, pass, LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, &token))
	{
		memset (&pi, 0, sizeof(pi));
		memset (&si, 0, sizeof(si));		

		if (! DuplicateTokenEx(token, MAXIMUM_ALLOWED, NULL, SecurityImpersonation, TokenPrimary, &token2))
		{
			PRINT_ERR(L"DuplicateTokenEx");
		}

		if (CreateProcessAsUser(token2, NULL, cmd, NULL, NULL, 1, NULL, NULL, NULL, &si, &pi))
		{
			puts ("Success");
			result = 1;
		}
		else
		{
			PRINT_ERR(L"CreateProcessAsUser");
		}

		CloseHandle(token2);
		CloseHandle(token);
	}
	else
	{
		PRINT_ERR(L"LogonUser");
	}

done:
	return result;
}

int wmain(int argc, wchar_t* argv[])
{
	if (argc == 4)
	{
		runas(L".", argv[1], argv[2], argv[3]);
	}
	else if (argc == 5)
	{
		runas(argv[1], argv[2], argv[3], argv[4]);
	}
	else
	{
		puts("Usage: runas [domain] user password cmd");
	}

	return 0;
}

