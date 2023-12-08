// TODO: 没有做Trace的关闭
// 
// 来自
// https://tttang.com/archive/1612/

#include <windows.h>
#include <evntcons.h>
#include <stdio.h>

#define AssemblyDCStart_V1 155

static GUID ClrRuntimeProviderGuid = { 0xe13c0d23, 0xccbc, 0x4e12, { 0x93, 0x1b, 0xd9, 0xcc, 0x2e, 0xee, 0x27, 0xe4 } };

const char name[] = "dotnet trace1";

#pragma pack(1)
typedef struct _AssemblyLoadUnloadRundown_V1
{
    ULONG64 AssemblyID;
    ULONG64 AppDomainID;
    ULONG64 BindingID;
    ULONG AssemblyFlags;
    WCHAR FullyQualifiedAssemblyName[1];
} AssemblyLoadUnloadRundown_V1, * PAssemblyLoadUnloadRundown_V1;
#pragma pack()

static void NTAPI ProcessEvent(PEVENT_RECORD EventRecord) {

    PEVENT_HEADER eventHeader = &EventRecord->EventHeader;
    PEVENT_DESCRIPTOR eventDescriptor = &eventHeader->EventDescriptor;
    AssemblyLoadUnloadRundown_V1* assemblyUserData;

    switch (eventDescriptor->Id) {
    case AssemblyDCStart_V1:
        assemblyUserData = (AssemblyLoadUnloadRundown_V1*)EventRecord->UserData;
        wprintf(L"[%d] - Assembly: %s\n", eventHeader->ProcessId, assemblyUserData->FullyQualifiedAssemblyName);
        break;
    }
}

int main(void)
{
    TRACEHANDLE hTrace = 0;
    ULONG result, bufferSize;
    EVENT_TRACE_LOGFILEA trace;
    EVENT_TRACE_PROPERTIES* traceProp;

    printf(".net_ETW_finder\n\n");

    memset(&trace, 0, sizeof(EVENT_TRACE_LOGFILEA));
    trace.ProcessTraceMode = PROCESS_TRACE_MODE_REAL_TIME | PROCESS_TRACE_MODE_EVENT_RECORD;
    trace.LoggerName = (LPSTR)name;
    trace.EventRecordCallback = (PEVENT_RECORD_CALLBACK)ProcessEvent;

    bufferSize = sizeof(EVENT_TRACE_PROPERTIES) + strlen(name) + 1;

    traceProp = (EVENT_TRACE_PROPERTIES*)LocalAlloc(LPTR, bufferSize);
    traceProp->Wnode.BufferSize = bufferSize;
    traceProp->Wnode.ClientContext = 2;
    traceProp->Wnode.Flags = WNODE_FLAG_TRACED_GUID;
    traceProp->LogFileMode = EVENT_TRACE_REAL_TIME_MODE | EVENT_TRACE_USE_PAGED_MEMORY;
    traceProp->LogFileNameOffset = 0;
    traceProp->LoggerNameOffset = sizeof(EVENT_TRACE_PROPERTIES);

    if ((result = StartTraceA(&hTrace, (LPCSTR)name, traceProp)) != ERROR_SUCCESS) {
        printf("[!] Error starting trace: %d\n", result);
        return 1;
    }

    if ((result = EnableTraceEx(
        &ClrRuntimeProviderGuid,
        NULL,
        hTrace,
        1,
        TRACE_LEVEL_VERBOSE,
        0x8, // LoaderKeyword
        0,
        0,
        NULL
    )) != ERROR_SUCCESS) {
        printf("[!] Error EnableTraceEx\n");
        return 2;
    }

    hTrace = OpenTraceA(&trace);
    if (hTrace == INVALID_PROCESSTRACE_HANDLE) {
        printf("[!] Error OpenTrace\n");
        return 3;
    }

    result = ProcessTrace(&hTrace, 1, NULL, NULL);
    if (result != ERROR_SUCCESS) {
        printf("[!] Error ProcessTrace\n");
        return 4;
    }

    return 0;
}