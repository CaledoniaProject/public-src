import ctypes
import ctypes.util
import sys

def run_code_windows(shellcode):
    """Run the specified shellcode on Windows"""
    k32 = ctypes.windll.kernel32
    k32.VirtualAlloc.restype = ctypes.c_void_p
    int_p = ctypes.POINTER(ctypes.c_int)
    k32.VirtualProtect.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                                   int_p]

    # Allocate RW memory of type MEM_COMMIT | MEM_RESERVE (=0x1000|0x2000)
    # PAGE_READWRITE = 4
    mem = k32.VirtualAlloc(0, len(shellcode), 0x3000, 4)
    if not mem:
        sys.stderr.write("VirtualAlloc: {}\n".format(ctypes.FormatError()))
        return 1

    # Copy the shellcode
    ctypes.memmove(mem, shellcode, len(shellcode))

    # Change protection to PAGE_EXECUTE_READ = 0x20
    oldprot = ctypes.c_int()
    if not k32.VirtualProtect(mem, len(shellcode), 32, ctypes.byref(oldprot)):
        sys.stderr.write("VirtualProtect: {}\n".format(ctypes.FormatError()))
        return 1

    # Run!
    return ctypes.CFUNCTYPE(ctypes.c_int)(mem)()

def run_code_linux(shellcode):
    libc = ctypes.CDLL(ctypes.util.find_library('c'))
    libc.mmap.restype = ctypes.c_void_p
    libc.mprotect.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]

    # Allocate memory with a RW private anonymous mmap
    # PROT_READ=1, PROT_WRITE=2, PROT_EXEC=4
    mem = libc.mmap(0, len(shellcode), 3, 0x22, -1, 0)
    if int(mem) & 0xffffffff == 0xffffffff:
        libc.perror(b"mmap")
        return 1

    # Copy the shellcode
    ctypes.memmove(mem, shellcode, len(shellcode))

    # Change protection to RX
    if libc.mprotect(mem, len(shellcode), 5) == -1:
        libc.perror(b"mprotect")
        return 1

    # Run!
    return ctypes.CFUNCTYPE(ctypes.c_int)(mem)()

# executes /bin/sh
SHELLCODE= "\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05"
run_code_linux(SHELLCODE)
