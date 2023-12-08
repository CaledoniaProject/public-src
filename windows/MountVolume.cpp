#include <windows.h>
#include <stdio.h>

int main(int argc, char** argv)
{
    HANDLE FindHandle = INVALID_HANDLE_VALUE;
    WCHAR  VolumeName[MAX_PATH] = L"";

    FindHandle = FindFirstVolumeW(VolumeName, ARRAYSIZE(VolumeName));
    if (FindHandle == INVALID_HANDLE_VALUE)
    {
        fwprintf(stderr, L"FindFirstVolumeW(): %d\n", GetLastError());
        return 0;
    }

    while (1)
    {
        wprintf(L"Volume name: %ws\n", VolumeName);
        if (!SetVolumeMountPointW(L"C:\\vol1\\", VolumeName))
        {
            fwprintf(stderr, L"SetVolumeMountPointW(): %d\n", GetLastError());
        }
        
        if (!DeleteVolumeMountPointW(L"C:\\vol1\\"))
        {
            fwprintf(stderr, L"DeleteVolumeMountPointW(): %d\n", GetLastError());
        }

        if (!FindNextVolumeW(FindHandle, VolumeName, ARRAYSIZE(VolumeName)))
        {
            if (GetLastError() != ERROR_NO_MORE_FILES)
            {
                fwprintf(stderr, L"FindNextVolumeW(): %d\n", GetLastError());
            }

            break;
        }
    }

    FindVolumeClose(FindHandle);
    return 0;
}