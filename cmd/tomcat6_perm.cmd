@echo off

set user=tomcat6
set docroot=tomcat

net user %user% /random:14 /ad

icacls %docroot% /q /reset /t
icacls %docroot% /q /remove Users /t

icacls "%docroot%" /q /grant %user%:(OI)(CI)R
icacls "%docroot%/work" /q /grant %user%:(OI)(CI)F
icacls "%docroot%/logs" /q /grant %user%:(OI)(CI)F
icacls "%docroot%/temp" /q /grant %user%:(OI)(CI)F
