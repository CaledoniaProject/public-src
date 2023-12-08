[bits 16]    ; use 16 bits
[org 0x7c00] ; sets the start address

init: 
  mov si, msg  ; loads the address of "msg" into SI register
  mov ah, 0x0e ; sets AH to 0xe (function teletype)
print_char:
  lodsb     ; loads the current byte from SI into AL and increments the address in SI
  cmp al, 0 ; compares AL to zero
  je done   ; if AL == 0, jump to "done"
  int 0x10  ; print to screen using function 0xe of interrupt 0x10
  jmp print_char ; repeat with next byte
done:
  hlt ; stop execution

msg: db "Hello world!", 0 ; we need to explicitely put the zero byte here

times 510-($-$$) db 0           ; fill the output file with zeroes until 510 bytes are full
dw 0xaa55                       ; magic number that tells the BIOS this is bootable