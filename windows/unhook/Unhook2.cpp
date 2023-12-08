#include <windows.h>
#include <Shlwapi.h>
#include <iostream>
#include <dbghelp.h>
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "dbghelp.lib")

PVOID MapBinary(LPCSTR Path)
{
	LPVOID Map = NULL;
	HANDLE hMapping;
	HANDLE hFile;

	hFile = CreateFileA(Path, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, 0, 0);
	if (hFile != INVALID_HANDLE_VALUE)
	{
		hMapping = CreateFileMappingA(hFile, 0, PAGE_READONLY | SEC_IMAGE, 0, 0, 0);
		if (hMapping != INVALID_HANDLE_VALUE)
		{
			Map = MapViewOfFile(hMapping, FILE_MAP_READ, 0, 0, 0);
			CloseHandle(hMapping);
		}

		CloseHandle(hFile);
	}

	return Map;
}

VOID UnhookModuleExports(HMODULE hModule)
{
	CHAR szModuleFileName[MAX_PATH];
	ZeroMemory(szModuleFileName, sizeof(szModuleFileName));

	if (GetModuleFileNameA(hModule, szModuleFileName, sizeof(szModuleFileName)) == 0)
	{
		fprintf(stderr, "GetModuleFileNameA() failed: %d\n", GetLastError());
		return;
	}

	PVOID pMap = MapBinary(szModuleFileName);
	if (pMap)
	{
		PIMAGE_NT_HEADERS pNtHeaders = (PIMAGE_NT_HEADERS)ImageNtHeader(hModule);
		if (pNtHeaders)
		{
			DWORD dwExportsSize;
			PIMAGE_EXPORT_DIRECTORY ExportDirectory = (PIMAGE_EXPORT_DIRECTORY)ImageDirectoryEntryToData((PVOID)hModule, TRUE, IMAGE_DIRECTORY_ENTRY_EXPORT, &dwExportsSize);
			if (ExportDirectory && dwExportsSize)
			{
				PUSHORT Ords = (PUSHORT)((DWORD_PTR)hModule + ExportDirectory->AddressOfNameOrdinals);
				PULONG EntriesRva = (PULONG)((DWORD_PTR)hModule + ExportDirectory->AddressOfFunctions);
				PULONG Names = (PULONG)((DWORD_PTR)hModule + ExportDirectory->AddressOfNames);

				for (ULONG cEntry = 0; cEntry < ExportDirectory->NumberOfNames; cEntry++)
				{
					ULONG StartSize = 10;
					PVOID ApiStart = (PVOID)((DWORD_PTR)hModule + EntriesRva[Ords[cEntry]]);
					PVOID ApiOriginalStart = (PVOID)((DWORD_PTR)pMap + EntriesRva[Ords[cEntry]]);

					if (memcmp(ApiStart, ApiOriginalStart, StartSize))
					{
						BOOL bRestore = TRUE;

						printf("Hook found %s - %08x - %s ...", PathFindFileNameA(szModuleFileName), ApiStart, ((DWORD_PTR)hModule + Names[cEntry]));

						if (bRestore)
						{
							SIZE_T Written;
							if (WriteProcessMemory(GetCurrentProcess(), ApiStart, ApiOriginalStart, StartSize, &Written))
							{
								printf("Restored.\n");
							}
							else
							{
								printf(__FUNCTION__"(): WriteProcessMemory failed with error %lx\n", GetLastError());
							}
						}
					}
				}
			}
		}

		UnmapViewOfFile(pMap);
	}
}

int main()
{
	getchar();
	UnhookModuleExports(GetModuleHandleA("kernel32"));
	UnhookModuleExports(GetModuleHandleA("ntdll"));
	UnhookModuleExports(GetModuleHandleA("advapi32"));
	//Sleep(30000);
	return 0;
}
