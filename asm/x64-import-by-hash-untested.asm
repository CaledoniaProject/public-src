; https://emsea.github.io/2017/12/04/import-by-hash/
; https://flatassembler.net/download.php
; x64 import by hash shellcode - 使用 fasm 编译 - 未测试

format PE64 GUI
entry find_kernel32

  find_kernel32:
    .alloc_granularity = 10000h

    ; Obtain base of kernel32.dll in RBX
    mov rbx, [rsp]  ; return address to kernel32 loader function
    xor bx, bx      ; align address to 64k boundaries (allocation granularity)
    sub rbx, .alloc_granularity

    lea rbp, [__imp_tab_start]
    sub rsp, 8*5    ; reserve stack for API use and make stack dqword aligned

  find_export_dir:
    .e_lfanew   = 3Ch
    .data_dir_0 = 88h

    ; Obtain IMAGE_EXPORT_DIRECTORY address in RAX
    mov eax, [rbx + .e_lfanew]
    mov eax, [rbx + rax + .data_dir_0]
    add rax, rbx


  read_export_dir:
    .export_names_num  = 18h
    .export_funcs_addr = 1Ch
    .export_names_addr = 20h
    .export_ords_addr  = 24h

    ; Obtain info from IMAGE_EXPORT_DIRECTORY
    mov r13d, [rax + .export_funcs_addr] ; AddressOfFunctions
    mov r14d, [rax + .export_names_addr] ; AddressOfNames
    mov r15d, [rax + .export_ords_addr]  ; AddressOfNameOrdinals
    mov r12d, [rax + .export_names_num]  ; NumberOfNames
    add r13, rbx
    add r14, rbx
    add r15, rbx


    xor ecx, ecx
  find_exports:
    mov esi, [r14 + rcx*4] ; use rcx to index AddressOfNames getting cur func name RVA
    add rsi, rbx

  ; hash export name to compare to imp tbl entry
    mov edx, 5381 ; edx contains hash
  .djb2:           
    mov eax, edx
    shl edx, 5
    add edx, eax
    xor eax, eax
    lodsb
    add edx, eax
    test eax, eax
    jnz .djb2

  ; locate imp table entry
    mov rsi, rbp
  .find_table_entry:
    lodsq
    test eax, eax
    jz .next_export        ; we have hit the table's null terminator
    cmp eax, edx
    jne .find_table_entry

  .get_export_addr:
    xor eax, eax           ; not needed if eax is already 0
    mov ax, [r15 + rcx*2]  ; get export's index into AddressOfFunctions
    mov eax, [r13 + rax*4] ; get export address rva from AddressOfFunctions
    add rax, rbx
    mov [rsi - 8], rax     ; populate imp table entry with address

  ; go to next export
  .next_export:
    inc rcx
    cmp rcx, r12
    jl find_exports

  ; rcx big enough because size of # exports
  next_dll:
    mov rdi, rbp
    xor eax, eax
    repnz scasq      ; find next dll table
    mov rsi, rdi
    lodsb            ; increments rsi over size byte 
    test al, al      ; the increment is why `cmp byte [rdi], 0` (3 bytes too) isnt used
    jz done_importing
    lea rbp, [rsi + rax - 1]  ; rax contains size byte
    mov rcx, rsi
    call [LoadLibraryA]
    mov rbx, rax
    jmp find_export_dir


  done_importing:
    ; call main

    xor r9d, r9d
    lea r8, [_msg]
    lea rdx, [_msg]
    xor ecx, ecx
    call [MessageBoxA]

    xor ecx, ecx
    call [ExitProcess]


  _msg db 'hello tiny world!', 0


  macro import_start {}
  macro import_end { dd 0 }

  macro use dll, [imp_name] {
      common
        imp_num = 0

        db @f - $, dll, 0
        align 8
        @@:

      forward
          local imp, imp_len, i, h, c
          virtual at 0
              imp::
                  db `imp_name
                  db 0
              imp_len = $ - 1
          end virtual

          ; hash using djb2
          i = 0
          h = 5381
          while i <= imp_len
              load c byte from imp:i
              h = ((h shl 5) + h + c) mod 0x100000000
              i = i + 1
          end while

          if dll eq 'kernel32' & imp_num = 0
            #__imp_tab_start:
          end if

          label imp_name:qword
            dd h, 0

          imp_num = imp_num + 1
      common
          dq 0  ; terminate table entry
  }

  ; 115 bytes table, 172 bytes import asm
  ; equivalent default imp table is 358 bytes saving 71 bytes already
  ; with this small table
  import_start
    use 'kernel32',\
      AcquireSRWLockExclusive,\
      GetProcessAffinityMask,\
      LoadLibraryA,\
      GetProcAddress,\
      ExitProcess

    use 'user32',\
      DispatchMessageA,\
      MessageBoxA,\
      DestroyWindow
  import_end

