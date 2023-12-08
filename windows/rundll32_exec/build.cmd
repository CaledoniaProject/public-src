@echo off

cd %~dp0
cl dllmain.cpp dllmain.def /MT /LD /Ferundll32_exec.dll
del dllmain.exp dllmain.lib dllmain.obj
