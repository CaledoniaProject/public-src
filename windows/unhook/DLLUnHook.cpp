// 参考
// https://passthehashbrowns.github.io/hook-integrity-checks
#include <windows.h>
#include <iostream>
#include <psapi.h>

void UnhookDLL(const char* filename, const char* name)
{
    MODULEINFO moduleInfo;
    HMODULE module;
    HANDLE dllFile = INVALID_HANDLE_VALUE, dllFileMapping = NULL, process = GetCurrentProcess();
    char *dllBase = NULL, *dllMapAddress = NULL;
    PIMAGE_DOS_HEADER dosHeader;
    PIMAGE_NT_HEADERS ntHeader;

    module = GetModuleHandleA(name);
    if (module == NULL)
    {
        fprintf(stderr, "GetModuleHandleA() on %s: %d\n", name, GetLastError());
        return;
    }

    if (!GetModuleInformation(process, module, &moduleInfo, sizeof(MODULEINFO)))
    {
        fprintf(stderr, "GetModuleInformation() on %s: %d\n", name, GetLastError());
        return;
    }

    dllFile = CreateFileA(filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
    if (dllFile == INVALID_HANDLE_VALUE)
    {
        fprintf(stderr, "CreateFileA() on %s: %d\n", filename, GetLastError());
        goto end;
    }

    dllFileMapping = CreateFileMapping(dllFile, NULL, PAGE_READONLY | SEC_IMAGE, 0, 0, NULL);
    if (dllFileMapping == NULL)
    {
        fprintf(stderr, "CreateFileMapping() on %s: %d\n", filename, GetLastError());
        goto end;
    }

    dllMapAddress = (char *) MapViewOfFile(dllFileMapping, FILE_MAP_READ, 0, 0, 0);
    if (dllMapAddress == NULL)
    {
        fprintf(stderr, "MapViewOfFile() on %s: %d\n", filename, GetLastError());
        goto end;
    }

    dllBase = (char *) moduleInfo.lpBaseOfDll;
    dosHeader = (PIMAGE_DOS_HEADER)dllBase;
    ntHeader = (PIMAGE_NT_HEADERS)((DWORD_PTR)dllBase + dosHeader->e_lfanew);

    for (WORD i = 0; i < ntHeader->FileHeader.NumberOfSections; i++)
    {
        PIMAGE_SECTION_HEADER sectionHeader = (PIMAGE_SECTION_HEADER)((DWORD_PTR)IMAGE_FIRST_SECTION(ntHeader) + ((DWORD_PTR)IMAGE_SIZEOF_SECTION_HEADER * i));

        if (!strcmp((char*)sectionHeader->Name, ".text"))
        {
            DWORD oldProtection = 0;
            if (!VirtualProtect(dllBase + sectionHeader->VirtualAddress, sectionHeader->Misc.VirtualSize, PAGE_EXECUTE_READWRITE, &oldProtection))
            {
                fprintf(stderr, "VirtualProtect() on %s, size %d: %d\n", sectionHeader->Name, sectionHeader->Misc.VirtualSize, GetLastError());
                continue;
            }

            memcpy(dllBase + sectionHeader->VirtualAddress, (char *)dllMapAddress + sectionHeader->VirtualAddress, sectionHeader->Misc.VirtualSize);
            VirtualProtect(dllBase + sectionHeader->VirtualAddress, sectionHeader->Misc.VirtualSize, oldProtection, &oldProtection);

            printf("Restored section: %s\n", sectionHeader->Name);
        }
    }

end:

    if (dllMapAddress != NULL)
    {
        UnmapViewOfFile(dllMapAddress);
    }

    if (dllFileMapping != NULL)
    {
        CloseHandle(dllFileMapping);
    }

    if (dllFile != INVALID_HANDLE_VALUE)
    {
        CloseHandle(dllFile);
    }

    CloseHandle(process);
    FreeLibrary(module);
}

int main(int argc, char** argv)
{
    getchar();
    HANDLE handle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, GetCurrentProcessId());
    CloseHandle(handle);

    UnhookDLL("c:\\windows\\system32\\kernel32.dll", "kernel32.dll");
    UnhookDLL("c:\\windows\\system32\\ntdll.dll", "ntdll.dll");

    while (true)
    {
        HANDLE handle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, GetCurrentProcessId());
        CloseHandle(handle);
        Sleep(1000);
    }
}


