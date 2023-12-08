#define  WPON() \
	   __asm mov eax,cr0;\
	   __asm or eax,10000h;\
	   __asm mov cr0,eax;\
       __asm sti; 

#define  WPOFF()\
	   __asm cli;\
	   __asm mov eax,cr0;\
       __asm and eax,not 10000h;\
	   __asm mov cr0.eax;
