#include "stdafx.h"
#include <Windows.h>

WCHAR *g_szClassName = L"myWindow123";

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch(msg)
	{
	case WM_MBUTTONDBLCLK:
		puts("Triggered, OK");
		break;
	case WM_CLOSE:
		DestroyWindow(hwnd);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hwnd, msg, wParam, lParam);
	}
	return 0;
}

int _tmain(int argc, _TCHAR* argv[])
{
	WNDCLASSEX wc = { 0 };
	wc.cbSize        = sizeof(WNDCLASSEX);
	wc.lpfnWndProc   = WndProc;
	wc.lpszClassName = g_szClassName;

	if(! RegisterClassEx(&wc))
	{
		printf("RegisterClassEx: Error %d\n", GetLastError());
		return 0;
	}

	HWND hwnd  = CreateWindow(g_szClassName, NULL, NULL, 0, 0, 0, 0, NULL, NULL, NULL, NULL);
	if (hwnd == NULL)
	{
		printf("CreatWindow: Error %d\n", GetLastError());
		return -1;
	}

	HWND hwnd2 = FindWindow(g_szClassName, NULL);
	if (hwnd2 != NULL) {
		SendMessage(hwnd2, WM_MBUTTONDBLCLK, 0, 0);
	} else {
		printf("FindWindow: Error %d\n", GetLastError());
	}

	return 0;
}


