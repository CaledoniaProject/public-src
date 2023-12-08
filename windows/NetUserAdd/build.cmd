@echo off

cd %~dp0
cl /DUNICODE /MT main.cpp /FeNetUserAdd.exe
del *.obj
