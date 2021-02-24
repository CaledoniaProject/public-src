auto start = 0x1000F718;
auto i;
auto fp = fopen("z:\\shm\\hex.txt", "w");

for (i = 0; i < 0xFB44; i = i + 1) 
{
	fputc(Byte(start + i), fp);
}

fclose(fp);
