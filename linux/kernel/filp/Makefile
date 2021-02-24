obj-m += kwrite.o

ifndef uname
	uname=$(shell uname -r)
endif

build:
	make -C /lib/modules/$(uname)/build M=`pwd` modules

clean:
	make -C /lib/modules/$(uname)/build M=`pwd` clean