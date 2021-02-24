#include <iostream>
#include <windows.h>

#define payload (LPVOID) "test"
#define payload_size 4

int main()
{
    HANDLE hPrinter = NULL;
    DOC_INFO_1 docInfo;
    DWORD dwJob = 0, bytesWritten = 0;

    docInfo.pOutputFile = (LPWSTR) L"c:\\test.txt";
    docInfo.pDocName    = (LPWSTR) L"My Document";
    docInfo.pDatatype   = (LPWSTR) L"RAW";

    if (!OpenPrinter((LPWSTR) L"Microsoft XPS Document Writer", &hPrinter, NULL))
    {
        fprintf(stderr, "OpenPrinter(): %d\n", GetLastError());
        return 1;
    }

    dwJob = StartDocPrinter(hPrinter, 1, (LPBYTE)&docInfo);
    if (dwJob <= 0)
    {
        fprintf(stderr, "StartDocPrinter(): %d\n", GetLastError());
        return 1;
    }

    if (!WritePrinter(hPrinter, payload, payload_size, &bytesWritten))
    {
        fprintf(stderr, "WritePrinter(): %d\n", GetLastError());
        return 1;
    }

    EndDocPrinter(hPrinter);
    ClosePrinter(hPrinter);

    fprintf(stderr, "Wrote %d bytes\n", bytesWritten);

    return 0;
}


