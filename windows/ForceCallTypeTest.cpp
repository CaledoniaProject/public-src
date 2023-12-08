#include <windows.h>

typedef BOOL(*testFunc)(HANDLE, PBOOL);
testFunc func1 = NULL;

int main(int argc, char** argv)
{
	BOOL result = false;
	HMODULE mod = LoadLibraryA("kernel32.dll");
	func1 = (testFunc)GetProcAddress(mod, "IsWow64Process");
	func1(GetCurrentProcess(), &result);
	return 0;
}
