#include "stdafx.h"
#include <windows.h>
#include <stdio.h>

int main(void)
{
	SC_HANDLE schSCManager, schService;
	// The service executable location, just dummy here else make sure the executable is there :o)...
	// Well as a real example, we are going to create our own telnet service.
	// The executable for telnet is: C:\WINDOWS\system32\tlntsvr.exe
	LPCTSTR lpszBinaryPathName = L"%SystemRoot%\\system32\\tlntsvr.exe";
	// Service display name...
	LPCTSTR lpszDisplayName = L"App Readiness ";
	// Registry Subkey
	LPCTSTR lpszServiceName = L"MyTelnetSrv";
	// Open a handle to the SC Manager database...
	schSCManager = OpenSCManager(
		NULL, // local machine
		NULL, // SERVICES_ACTIVE_DATABASE database is opened by default
		SC_MANAGER_ALL_ACCESS); // full access rights
	if (NULL == schSCManager)
		printf("OpenSCManager() failed, error: %d.\n", GetLastError());
	else
		printf("OpenSCManager() looks OK.\n");
	// Create/install service...
	// If the function succeeds, the return value is a handle to the service. If the function fails, the return value is NULL.
	schService = CreateService(
		schSCManager, // SCManager database
		lpszServiceName, // name of service
		lpszDisplayName, // service name to display
		SERVICE_ALL_ACCESS, // desired access
		SERVICE_WIN32_OWN_PROCESS, // service type
		SERVICE_DEMAND_START, // start type
		SERVICE_ERROR_NORMAL, // error control type
		lpszBinaryPathName, // service's binary
		NULL, // no load ordering group
		NULL, // no tag identifier
		NULL, // no dependencies, for real telnet there are dependencies lor
		NULL, // LocalSystem account
		NULL); // no password
	if (schService == NULL)
	{
		printf("CreateService() failed, error: %ld\n", GetLastError());
		return FALSE;
	}
	else
	{
		printf("CreateService() for %S looks OK.\n", lpszServiceName);
		if (CloseServiceHandle(schService) == 0)
			printf("CloseServiceHandle() failed, Error: %d.\n", GetLastError());
		else
			printf("CloseServiceHandle() is OK.\n");
		return 0;
	}
}


