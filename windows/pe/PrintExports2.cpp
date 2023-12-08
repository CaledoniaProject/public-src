#include <windows.h>
#include <iostream>
#include <dbghelp.h>
#pragma comment(lib, "dbghelp.lib")

void PrintNames(HMODULE hModule)
{
    DWORD dwExportsSize;
    PIMAGE_NT_HEADERS pNtHeaders = (PIMAGE_NT_HEADERS)ImageNtHeader(hModule);
    PIMAGE_EXPORT_DIRECTORY ExportDirectory = (PIMAGE_EXPORT_DIRECTORY)ImageDirectoryEntryToData(hModule, TRUE, IMAGE_DIRECTORY_ENTRY_EXPORT, &dwExportsSize);
    PULONG Names = (PULONG)((DWORD_PTR)hModule + ExportDirectory->AddressOfNames);

    for (ULONG cEntry = 0; cEntry < ExportDirectory->NumberOfNames; cEntry++)
    {
        printf("%s\n", (char*)((DWORD_PTR)hModule + Names[cEntry]));
    }

}

int main()
{
    PrintNames(GetModuleHandleA("ntdll"));
    return 0;
}
