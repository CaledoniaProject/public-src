.386
.model flat,stdcall 

include windows.inc
include kernel32.inc
include user32.inc

includelib user32.lib
includelib kernel32.lib

.data

MsgBoxCaption  db "TEST",0 
MsgBoxText     db "Hello Message",0

.code

start:

invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK 
invoke ExitProcess, 0

end start
