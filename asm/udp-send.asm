.386
.model flat, stdcall

include windows.inc
include kernel32.inc
include ws2_32.inc
include user32.inc

includelib ws2_32.lib
includelib user32.lib
includelib kernel32.lib

.data

buffer    db "SomeMessage", 0
server    db "114.114.114.114", 0
port      DWORD 53
sock      DWORD ?
sin1      sockaddr_in <0>
sin2      sockaddr_in <0>
wsaData   WSADATA <0>
.code

start:

invoke WSAStartup, 202h, ADDR wsaData
.if eax != 0
	invoke WSAGetLastError
	invoke ExitProcess, 1
.endif

invoke socket, AF_INET, SOCK_DGRAM, IPPROTO_UDP
.if eax == INVALID_SOCKET
	invoke WSAGetLastError
	invoke ExitProcess, 2
.endif
mov sock, eax

mov sin1.sin_family, AF_INET
invoke htons, port
mov sin1.sin_port, ax

invoke inet_addr, ADDR server
mov sin1.sin_addr.S_un.S_addr, eax

invoke sendto, sock, ADDR buffer, sizeof buffer - 1, 0, ADDR sin1, sizeof sin1
.if eax == -1
    invoke WSAGetLastError
	invoke ExitProcess, 3
.endif

invoke MessageBox, NULL, ADDR buffer, ADDR buffer, MB_OK
invoke ExitProcess, 0

end start
