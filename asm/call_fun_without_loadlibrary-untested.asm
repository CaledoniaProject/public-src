; ------------------------------------------------
; call.asm - finds kernel32.dll in memory and 
; searches it's export table for LoadLibraryA() 
; and GetProcAddress(). From there, calling 
; functions that haven't been imported is trivial.
;
; :-)
;
; Assembled with:
;   nasm call.asm -fwin32 -o call.obj
;   gcc call.obj -o call.exe
;
; AdhesiveBall - August/2010
; ------------------------------------------------

[BITS 32]
global _WinMain@16



section .data
   WorkedMessage    db "Hello from an unimported function!", 0
   
   LoadLibraryName db "LoadLibraryA", 0
   LoadLibraryAddr dd 0xFFFFFFFF
   
   GetProcAddressName db "GetProcAddress", 0
   GetProcAddressAddr dd 0xFFFFFFFF
   
   MessageBoxName db "MessageBoxA", 0
   MessageBoxAddr dd 0xFFFFFFFF
   
   User32Name db "user32.dll", 0
   User32Addr dd 0xFFFFFFFF
   
   Kernel32Addr   dd 0xFFFFFFFF

section .text

; -----------------------------------------------
; void *FindKernel32Base(void)
; tries to find the base address of kernel32.dll
; returns NULL on error
; -----------------------------------------------

FindKernel32Base:
	  cld
	  mov edx, [fs:0x30]     ; get a pointer to the PEB
	  mov edx, [edx+0x0C]    ; get PEB->Ldr
	  mov edx, [edx+0x14]    ; get the first module from the InMemoryOrder module list
	next_mod:
	  mov esi, [edx+0x28]    ; get pointer to modules name (unicode string)
	  push 24                ; push down the length we want to check
	  pop ecx                ; set ecx to this length for the loop
	  xor edi, edi           ; clear edi which will store the hash of the module name
	loop_modname:
	  xor eax, eax           ; clear eax
	  lodsb                  ; read in the next byte of the name
	  cmp al, 'a'            ; some versions of Windows use lower case module names
	  jl not_lowercase
	  sub al, 0x20           ; if so normalise to uppercase
	not_lowercase:
	  ror edi, 13            ; rotate right our hash value
	  add edi, eax           ; add the next byte of the name to the hash
	  loop loop_modname      ; loop until we have read enough
	  cmp edi, 0x6A4ABC5B    ; compare the hash with that of KERNEL32.DLL
	  mov ebx, [edx+0x10]    ; get this modules base address
	  mov edx, [edx]         ; get the next module
	  jne next_mod           ; if it doesn't match, process the next module

      cmp word [ebx], 'MZ'   ; check MZ header
      je    FindKernel32Base_end
      xor ebx, ebx
FindKernel32Base_end:
	  mov eax, ebx;
      ret

   
; ------------------------------------------------------
; void *LoadFunction(HMODULE module, char *FunctionName)
; attempts to find the address of function by 
; walking module's Export Address Table
; ------------------------------------------------------
LoadK32Function:
   push    ebp
   mov    ebp, esp
   sub   esp, 12      ; make room for 3 DWORDS
   
   ; look at my stack frame, my stack frame's amazing
   ;------------------------------------
   ;          +-----------------------+  
   ; ebp-0x0C | PE Header             |
   ;          +-----------------------+
   ; ebp-0x08 | Export table addr     |
   ;          +-----------------------+
   ; ebp-0x04 | AddressOfNames        |
   ;          +-----------------------+
   ; .....
   ;          +-----------------------+
   ; ebp+0x08 | kernel32 base address |
   ;          +-----------------------+
   ; ebp+0x0C | function name         |
   ;          +-----------------------+
   ;------------------------------------
   
   
   
   mov    edi, [ebp + 0x08]    ; edi = DosHeader
   
   ; -------------------------
   ; verify MZ and PE headers
   ; -------------------------
   cmp word [edi], 'MZ'    
   jne    LoadK32Function_fail
   mov    edx, edi
   add    edx, [edi + 0x3C]    ; module + DosHeader->e_lfanew (edx = PeHeader)
   cmp word [edx], 'PE'
   jne    LoadK32Function_fail
   mov   [ebp - 0x0C], edx   ; save the PE header
   
   ; ------------------------------
   ; find the real addr of the EAT 
   ; ------------------------------
   mov    eax, [edx + 0x78]    ; OptionalHeader.DataDirectory[0].VirtualAddress
   add    eax, dword [ebp + 0x08] ; add the offset to the base address
   mov   [ebp - 0x08], eax   ; save it!
   
   ; ----------------------------------------
   ; find the real address of export names
   ; ----------------------------------------
   mov    eax, [eax + 0x20]   ; eax is still addr of EAT (0x20 = offset to ADdressOfNames)
   add    eax, dword [ebp + 0x08]
   mov    [ebp - 0x04], eax
   
   
   ; --------------------------------
   ; start looking for names!
   ; --------------------------------
   xor ecx, ecx
   LoadK32Function_loop_names:
      mov    edx, [ebp - 0x08]   ; EAT
      cmp    ecx, [edx + 0x18]   ; NumberOfNames
      jge LoadK32Function_fail
      
      ; --------------------------------------
      ; find the address of the function name
      ; --------------------------------------
      mov   ebx, [ebp - 0x04]   ; AddressOfNames
      mov   ebx, [ebx + ecx * 4]   ; RVA of string
      add   ebx, [ebp + 0x08]
      
      ; compare 'em!
      push dword [ebp + 0x0C]   ; FunctionName
      push    ebx      ; name of entry
      call    strcmp
      cmp    eax, 1
      je    LoadK32Function_found_api
      
      inc    ecx
      jmp    LoadK32Function_loop_names
      
LoadK32Function_found_api:
   ;------------------------------------------------------
   ; success! now all that's left is to go from the 
   ; AddressOfNames index to the AddressOfFunctions index
   ; -----------------------------------------------------
   
   ; First thing's first, find the AddressOfNameOrdinals address
   mov    eax, [ebp - 0x08]
   mov   eax, [eax + 0x24] ; AddressOfNameOrdinals offset
   add   eax, [ebp + 0x08]
   
   ; Now we gotta look up the ordinal corresponding to our api
   xor    ebx, ebx
   mov   bx, [eax + ecx * 2] ; ecx * 2 because it's an array of WORDS
   
   ; Next we find the AddressOfFunctions array
   mov   eax, [ebp - 0x08]
   mov   eax, [eax + 0x1C] ; AddressOfFunctions offset
   add   eax, [ebp + 0x08]
   
   ; and last we find the address of our api!
   mov   eax, [eax + ebx * 4]
   add   eax, [ebp + 0x08]
   
   jmp    LoadK32Function_end
LoadK32Function_fail:
   xor    eax, eax
LoadK32Function_end:
   mov    esp, ebp
   pop    ebp
   ret    8

   
   
   
   
   
   
   
; -------------------------------------------------------------
; unsigned int RVAToFileOffset(
; IMAGE_NT_HEADERS *ntHeader, unsigned long virtualAddr);
;
; Converts a relative virtual address to an offset in the file
; -------------------------------------------------------------
;RvaToFileOffset:
;   push    ebx
;   mov    eax, [esp + 0x08] ; eax = ntHeader
;   mov    ebx, [esp + 0x0C] ; ebx = virtualAddr
;   push    ecx
;   push    edx
;   xor    ecx, ecx
;   mov    cx, [eax + 0x06]    ; ecx = number of sections
;   lea    edx, [eax + 0xF8]    ; edx = first section
;   RvaToFileOffset_loop_sections:
;      push    ecx      ; used as a temporary variable throughout the loop
;      
;      ; -------------------------------------------------------------
;      ; check if the virtual address resides in the current function
;      ; -------------------------------------------------------------
;      cmp    ebx, [edx + 0x0C]   ; if(virtualAddr < section->VirtualAddress) continue;   
;      jl    RvaToFileOffset_continue
;      mov    ecx, [edx + 0x0C]   
;      add    ecx, [edx + 0x08]   ; ecx = section->VirtualAddress + section->VirtualSize
;      cmp    ebx, ecx      ; if(virtualAddr >= ecx) continue;
;      jge    RvaToFileOffset_continue
;   
;   RvaToFileOffset_DEBUGLABEL:
;      ; -------------------
;      ; Success! It's here
;      ; -------------------
;      sub    ebx, [edx + 0x0C] ; find the offset from the beginning of the section's virtual addr
;      add    ebx, [edx + 0x14] ; add it to the PointerToRawData member
;      jmp    RvaToFileOffset_success
;      
;;   RvaToFileOffset_continue:
;      add    edx, 0x28      ; edx += sizeof(IMAGE_SECTION_HEADER)
;      pop    ecx         ; restore for use as a counter
;      loop    RvaToFileOffset_loop_sections
;   
;   xor    eax, eax   ; baww
;   jmp    RvaToFileOffset_end
;   
;RvaToFileOffset_success:
;   pop    ecx   ; ecx will be on the stack 'coz of the loop so we need to fix it
;   mov    eax, ebx 
;RvaToFileOffset_end:
;   pop    edx
;   pop    ecx
;   pop    ebx
;   ret    8
   
   
   
   
   
   
   
   
   
   
; -------------------------------------------------
; int strcmp(char *a, char *b)
; returns 1 if the two strings are equal, 0 if not
; -------------------------------------------------
strcmp:
   push ebx
   strcmp_loop:
      mov    eax, [esp + 0x08]
      mov    al, byte [eax]
      mov    ebx, [esp + 0x0C]
      cmp    al, byte [ebx]
      jne    strcmp_not_equal
      cmp    al, 0
      je    strcmp_equal
      inc   dword [esp + 0x0C]
      inc    dword [esp + 0x08]
      jmp    strcmp_loop
   
   strcmp_not_equal:
      mov    eax, 0
      jmp    strcmp_end
   
   strcmp_equal:
      mov    eax, 1
      
strcmp_end:
   pop    ebx
   ret    8
   
   
; -----------------------------------------------
; kinda bloated but meh does it's job
_WinMain@16:
   call    FindKernel32Base
   cmp    eax, 0
   je    _WinMain_failed
   mov    [Kernel32Addr], eax
   
   ; find LoadLibrary()
   push    LoadLibraryName
   push    dword [Kernel32Addr]
   call    LoadK32Function
   cmp    eax, 0
   je    _WinMain_failed
   mov    [LoadLibraryAddr], eax
   
   ; find GetProcAddress()
   push    GetProcAddressName
   push    dword [Kernel32Addr]
   call    LoadK32Function
   cmp    eax, 0
   je   _WinMain_failed
   mov   [GetProcAddressAddr], eax
   
   ; load user32.dll
   push    User32Name
   call   [LoadLibraryAddr]
   cmp   eax, 0
   je   _WinMain_failed
   mov   [User32Addr], eax
   
   ; find MessageBox()
   push   MessageBoxName
   push dword [User32Addr]
   call    [GetProcAddressAddr]
   cmp    eax, 0
   je    _WinMain_failed
   mov   [MessageBoxAddr], eax
   
   push    0
   push    WorkedMessage
   push    WorkedMessage
   push    0
   call    [MessageBoxAddr]
   
_WinMain_worked:
;   push    0
;   push    WorkedMessage
;   push    WorkedMessage
;   push    0
;   call    _MessageBoxA@16
;   jmp    _WinMain_end
_WinMain_failed:
;   push    0
;   push    FailedMessage
;   push    FailedMessage
;   push    0
;   call    _MessageBoxA@16
_WinMain_end:
   ret    16
