// 无需mprotect，写不可写入的内存
// https://offlinemark.com/2021/05/12/an-obscure-quirk-of-proc/

#include <fstream>
#include <iostream>
#include <sys/mman.h>

/* Write @len bytes at @ptr to @addr in this address space using
 * /proc/self/mem.
 */
void memwrite(void *addr, char *ptr, size_t len) {
  std::ofstream ff("/proc/self/mem");
  ff.seekp(reinterpret_cast<size_t>(addr));
  ff.write(ptr, len);
  ff.flush();
}

int main(int argc, char **argv) {
  // Map an unwritable page. (read-only)
  auto mymap =
      (int *)mmap(NULL, 0x9000,
                  PROT_READ, // <<<<<<<<<<<<<<<<<<<<< READ ONLY <<<<<<<<
                  MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

  if (mymap == MAP_FAILED) {
    std::cout << "FAILED\n";
    return 1;
  }

  std::cout << "Allocated PROT_READ only memory: " << mymap << "\n";
  getchar();

  // Try to write to the unwritable page.
  memwrite(mymap, "\x40\x41\x41\x41", 4);
  std::cout << "did mymap[0] = 0x41414140 via proc self mem..";
  getchar();
  std::cout << "mymap[0] = 0x" << std::hex << mymap[0] << "\n";
  getchar();

  // Try to writ to the text segment (executable code) of libc.
  auto getchar_ptr = (char *)getchar;
  memwrite(getchar_ptr, "\xcc", 1);

  // Run the libc function whose code we modified. If the write worked,
  // we will get a SIGTRAP when the 0xcc executes.
  getchar();
}

