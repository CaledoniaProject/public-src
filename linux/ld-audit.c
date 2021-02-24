// https://labs.sentinelone.com/leveraging-ld_audit-to-beat-the-traditional-linux-library-preloading-technique/
// 这个加载更早，能用来监控 LD_PRELOAD
//
// LD_AUDIT=/tmp/xxx.so /bin/ls
#include <stdio.h>

__attribute__((constructor)) static void init(void) 
{
	puts("Loaded");
}

unsigned int la_version(unsigned int version)
{  
    return version;
}
