# 遇到错误退出
$ErrorActionPreference = "Stop"

# 设置允许 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName System.IO.Compression.FileSystem

$desktop   = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$build_dir = $env:temp + "\LaZagne-master"
$zip_path  = $env:temp + "\LaZagne-master.zip"
$out_dir   = $desktop + "\release"

Write-Host "[-] Creating release folder"
New-Item -ItemType Directory -Force -Path $out_dir | Out-Null

Write-Host "[-] Downloading from github"
$web = New-Object Net.Webclient;
$web.DownloadFile("https://github.com/AlessandroZ/LaZagne/archive/master.zip", $zip_path);

# 解压缩
Write-Host "[-] Expanding zip"
if (Test-Path -Path $build_dir)
{
    cmd /c "del /Q /F /S $build_dir > nul" 
    cmd /c rmdir "$build_dir" /q /s
}

[System.IO.Compression.ZipFile]::ExtractToDirectory($zip_path, "$build_dir\..")
Remove-Item –Path $zip_path

# 开始编译

$setup_py = @'
from distutils.core import setup
import py2exe, sys, os

sys.argv.append('py2exe')
setup(options={'py2exe':{'bundle_files':1,'compressed':True}},
      console=['laZagne.py'],
      zipfile=None)
'@

Set-Location -Path "$build_dir\Windows"

Write-Host "[-] Start compilation"
Set-Content -Path "setup.py" -Value $setup_py
cmd /c c:\python3\scripts\pip install -r requirement.txt
cmd /c c:\python3\python setup.py py2exe

Write-Host "[-] Copying files to $out_dir"
Copy-Item "dist\laZagne.exe" -Destination "$out_dir\lazagne.exe"

Write-Host "[-] Cleaning up"
if (Test-Path -Path $build_dir)
{
    cd c:\
    cmd /c "del /Q /F /S $build_dir > nul"
    cmd /c rmdir "$build_dir" /q /s
}



