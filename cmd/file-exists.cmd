@echo off

set lock_path="%temp%\block.txt"
if exist %lock_path% (
    exit
) else (
	echo loaded > %lock_path%
	calc
)
