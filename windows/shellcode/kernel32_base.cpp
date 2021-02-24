// 寻找 kernel32 加载基地址

#include "stdafx.h"
#include <Windows.h>

DWORD find_k32addr_1()
{
	DWORD k32addr;

	__asm
	{
		 xor ebx, ebx               // clear ebx
		 mov ebx, fs:[ 0x30 ]       // get a pointer to the PEB
		 mov ebx, [ ebx + 0x0C ]    // get PEB->Ldr
		 mov ebx, [ ebx + 0x14 ]    // get PEB->Ldr.InMemoryOrderModuleList.Flink (1st entry)
		 mov ebx, [ ebx ]           // get the next entry (2nd entry)
		 mov ebx, [ ebx ]           // get the next entry (3rd entry)
		 mov ebx, [ ebx + 0x10 ]    // get the 3rd entries base address (kernel32.dll)
		 mov k32addr, ebx;
	}

	return k32addr;
}

DWORD find_k32addr_2()
{
	DWORD k32addr;

	__asm
	{
	  cld
	  mov edx, fs:[0x30]     // get a pointer to the PEB
	  mov edx, [edx+0x0C]    // get PEB->Ldr
	  mov edx, [edx+0x14]    // get the first module from the InMemoryOrder module list
	next_mod:
	  mov esi, [edx+0x28]    // get pointer to modules name (unicode string)
	  push 24                // push down the length we want to check
	  pop ecx                // set ecx to this length for the loop
	  xor edi, edi           // clear edi which will store the hash of the module name
	loop_modname:
	  xor eax, eax           // clear eax
	  lodsb                  // read in the next byte of the name
	  cmp al, 'a'            // some versions of Windows use lower case module names
	  jl not_lowercase
	  sub al, 0x20           // if so normalise to uppercase
	not_lowercase:
	  ror edi, 13            // rotate right our hash value
	  add edi, eax           // add the next byte of the name to the hash
	  loop loop_modname      // loop until we have read enough
	  cmp edi, 0x6A4ABC5B    // compare the hash with that of KERNEL32.DLL
	  mov ebx, [edx+0x10]    // get this modules base address
	  mov edx, [edx]         // get the next module
	  jne next_mod           // if it doesn't match, process the next module
	  mov k32addr, ebx;
	}

	return k32addr;
}

int _tmain(int argc, _TCHAR* argv[])
{
	printf ("0x%x\n", find_k32addr_1());
	printf ("0x%x\n", find_k32addr_2());

	return 0;
}


