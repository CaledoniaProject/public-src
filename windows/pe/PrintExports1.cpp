#include <windows.h>
#include <stdio.h>

int main(int argc, char** argv)
{
	HMODULE lib = LoadLibraryEx(L"kernelbase.dll", NULL, DONT_RESOLVE_DLL_REFERENCES);
	PIMAGE_NT_HEADERS header = (PIMAGE_NT_HEADERS)((BYTE*)lib + ((PIMAGE_DOS_HEADER)lib)->e_lfanew);
	PIMAGE_EXPORT_DIRECTORY exports = (PIMAGE_EXPORT_DIRECTORY)((BYTE*)lib + header->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);
	BYTE** names = (BYTE**)((int)lib + exports->AddressOfNames);

	for (int i = 0; i < exports->NumberOfNames; i++)
		printf("Export: %s\n", (BYTE*)lib + (int)names[i]);
	return 0;
}
