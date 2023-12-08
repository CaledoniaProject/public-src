@echo off

REM 读取用户列表，创建用户并添加到指定的组，然后创建用户目录并授权

set share_dir=d:

if [%1] == [] goto usage

call :add_users %1
goto :eof

REM
REM add_users
REM
:add_users
setlocal EnableDelayedExpansion
set /a counter=0

for /f ^"usebackq^ eol^=^

^ delims^=^" %%a in (%1) do (
         if not %%a == "" (
	         net user "%%a" /random:14 /ad
        	 net localgroup "Remote Desktop Users" "%%a" /ad

                if not exist "%share_dir%\%%a" mkdir "%share_dir%\%%a"
		icacls "%share_dir%\%%a" /q /reset /t
		icacls "%share_dir%\%%a" /inheritance:d 
		icacls "%share_dir%\%%a" /q /remove Users /t
		icacls "%share_dir%\%%a" /q /grant "%%a:(OI)(CI)F"

 	 )
)

goto :eof

:usage
echo Usage: add_users d:\userlist.txt
