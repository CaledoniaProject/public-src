@echo off

cd %~dp0
powershell -ep bypass -nop -file build-ysoserial.net.ps1
