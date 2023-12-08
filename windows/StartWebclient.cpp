#include <Windows.h>
#include <evntprov.h>
 
int main()
{
    const GUID _MS_Windows_WebClntLookupServiceTrigger_Provider =
    { 0x22B6D684, 0xFA63, 0x4578,
    { 0x87, 0xC9, 0xEF, 0xFC, 0xBE, 0x66, 0x43, 0xC7 } };
 
    REGHANDLE Handle;
    bool success = false;
 
    if (EventRegister(&_MS_Windows_WebClntLookupServiceTrigger_Provider,
        nullptr, nullptr, &Handle) == ERROR_SUCCESS)
    {
        EVENT_DESCRIPTOR desc;
        EventDescCreate(&desc, 1, 0, 0, 4, 0, 0, 0);
        success = EventWrite(Handle, &desc, 0, nullptr) == ERROR_SUCCESS;
        EventUnregister(Handle);
    }
 
    return success;
}
