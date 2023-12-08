ksyms = open(r"D:\ksyms") #path to the ksyms file
for line in ksyms:
addr = int(line[:8], 16)
name = line[9:-1] # use line[11:-1] in case of kallsyms
idaapi.set_debug_name(addr, name)
set_name(addr, name, SN_NOWARN)
msg("%08X: %s\n"%(addr, name))
