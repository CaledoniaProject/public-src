#include <windows.h>
#include <string.h>
#include <stdio.h>
#pragma comment(lib, "shell32.lib")

extern "C" __declspec(dllexport) void CALLBACK exec(HWND, HINSTANCE, LPSTR lpszCmdLine, int)
{
	if (lpszCmdLine)
	{
		PROCESS_INFORMATION pi;
		STARTUPINFOA si;

		ZeroMemory (&si, sizeof (si));
		ZeroMemory (&pi, sizeof (pi));
		si.dwFlags     = STARTF_USESHOWWINDOW;
		si.wShowWindow = FALSE;
		si.cb          = sizeof (si);
		CreateProcess(NULL, lpszCmdLine, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);
	}
}
