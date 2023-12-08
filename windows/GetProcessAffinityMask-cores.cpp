#include <Windows.h>
#include <iostream>
using namespace std;

int main() {
    DWORD_PTR processAffinityMask, systemAffinityMask;
    if (!GetProcessAffinityMask(GetCurrentProcess(), &processAffinityMask, &systemAffinityMask))
    {
    	cout << "GetProcessAffinityMask(): " << GetLastError() << endl;
        return -1;
    }

    int result = 0, tmp = 0;
    for (int i = 0; i < 32; i ++) {
    	tmp = result + 1;
    	if ((systemAffinityMask & (1 << i)) == 0) {
    		tmp = result;
    	}

    	result = tmp;
    }

    cout << "core core: " << result << endl;
    return 0;
}