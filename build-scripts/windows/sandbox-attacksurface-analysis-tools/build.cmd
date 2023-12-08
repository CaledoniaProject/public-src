@echo off

cd %~dp0
powershell -ep bypass -nop -file build-sandbox-attacksurface-analysis-tools.ps1
