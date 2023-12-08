# 类似硬链接，不是快捷方式，也不是软链接
New-Item -Type junction -Path test -Source c:\windows
