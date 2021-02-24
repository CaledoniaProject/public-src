#include <Windows.h>

int main(int argc, char* argv[])
{
	HWND root = GetDesktopWindow();
	DWORD pid = 0;
	GetWindowThreadProcessId(root, &pid);
	printf("csrss has pid %d\n", pid);
	return 0;
}

