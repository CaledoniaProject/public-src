@echo off

cd %~dp0
powershell -ep bypass -nop -file build-lazagne.ps1
