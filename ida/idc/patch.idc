#include <idc.idc>

static main ()
{
    auto addr, i;

    addr = FindBinary (BeginEA(), 0x01, "51 52 53");
    if (addr != BADADDR)
    {
        Message ("Got it: %x", addr);
        for (i = addr; i <= addr + 3; ++ i)
        {
            Message ("Patched %x", i);
            PatchByte (i, Byte (i) ^ 0x10);
        }
    }
    else
    {
        Message ("Bad day!");
    }
}
