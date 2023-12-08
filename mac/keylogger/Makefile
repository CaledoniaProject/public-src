build:
	gcc -dynamiclib main.m -o keylogger.dylib -framework Foundation -framework Appkit -arch x86_64

test: build
	DYLD_INSERT_LIBRARIES=$(PWD)/keylogger.dylib '/Applications/MacVim.app/Contents/MacOS/MacVim'
