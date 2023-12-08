#include <iostream>
#include <windows.h>

int main(int argc, char **argv)
{
    // 防止崩溃弹窗；critical-error 错误消息交给调用者处理
    SetErrorMode(SEM_NOGPFAULTERRORBOX | SEM_FAILCRITICALERRORS);

    char* a = (char*)argv[2];
    a[0] = 'o';
    printf("got %s\n", argv[2]);
}

