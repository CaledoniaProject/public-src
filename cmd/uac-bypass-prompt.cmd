@echo off

call :isAdmin

if %errorlevel% == 0 (
	goto :run
) else (
	goto :UACPrompt
)

exit

:isAdmin
fsutil dirty query %systemdrive% >nul
exit /B

:run
cmd
exit

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "cmd.exe", "/c %~s0 %~1", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit

