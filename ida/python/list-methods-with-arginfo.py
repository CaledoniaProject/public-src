import idautils
import idaapi

ti = idaapi.tinfo_t()
for ea in idautils.Functions():
    name = idaapi.get_func_name(ea)
    if (idaapi.get_tinfo(ti, ea)):
        print("%08X: %s" % (ea, ti._print(name)))
