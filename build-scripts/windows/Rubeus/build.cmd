@echo off

cd %~dp0
powershell -ep bypass -nop -file build-Rubeus.ps1
