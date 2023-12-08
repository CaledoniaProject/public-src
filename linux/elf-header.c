#include <stdio.h>
#include <stdlib.h>
#include <elf.h>
#include <sys/stat.h>

int main (int argc , char **argv) 
{
	const char *filename = "/bin/ls";
	struct stat sbuf;

	FILE *fp = fopen (filename, "r");
	if (fp == NULL)
	{
		perror("fopen");
		return 1;
	}

	if (stat (filename, &sbuf))
	{
		perror("stat");
		return 1;
	}

	char *mem = malloc(sbuf.st_size + 1);
	if (! mem)
	{
		perror("malloc");
		return 1;
	}

	if (fread (mem, 1, sbuf.st_size, fp) != sbuf.st_size)
	{
		perror("fread");
		return 1;
	}

	if (mem[EI_CLASS] == ELFCLASS32)
	{
		Elf32_Ehdr *ehdr = (Elf32_Ehdr*)mem;
		printf("0x%X\n", ehdr->e_entry);
	}
	else if (mem[EI_CLASS] == ELFCLASS64)
	{
		Elf64_Ehdr *ehdr = (Elf64_Ehdr*)mem;
		printf("0x%lX\n", ehdr->e_entry);
	}
	else
	{
		puts("Unknown class");
	}

	return 0;
}

