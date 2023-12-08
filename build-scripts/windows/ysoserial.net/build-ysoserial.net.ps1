# 遇到错误退出
$ErrorActionPreference = "Stop"

# 设置允许 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName System.IO.Compression.FileSystem

$desktop   = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$build_dir = $env:temp + "\ysoserial.net-master"
$zip_path  = $env:temp + "\ysoserial.net-master.zip"
$out_dir   = $desktop + "\release"

Write-Host "[-] Creating release folder"
New-Item -ItemType Directory -Force -Path $out_dir | Out-Null

Write-Host "[-] Downloading from github"
$web = New-Object Net.Webclient;
$web.DownloadFile("https://github.com/pwntester/ysoserial.net/archive/master.zip", $zip_path);

# 解压缩
Write-Host "[-] Expanding zip"
if (Test-Path -Path $build_dir)
{
    cmd /c "del /Q /F /S $build_dir > nul" 
    cmd /c rmdir "$build_dir" /q /s
}

[System.IO.Compression.ZipFile]::ExtractToDirectory($zip_path, "$build_dir\..")
Remove-Item -Path $zip_path

# 开始编译
Write-Host "[-] Start compilation"
cd $build_dir

# 修正 TargetFrameworkVersion
(Get-Content "ysoserial/ysoserial.csproj") -Replace '<TargetFrameworkVersion>v4.5.2</TargetFrameworkVersion>', '<TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>' | Set-Content "ysoserial/ysoserial.csproj"

# 恢复 nuget 包
Write-Host "[-] Restoring nuget packages"
cmd /c c:\windows\nuget.exe restore ysoserial.sln

cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat" && msbuild /p:Configuration=Release /p:Platform="Any CPU"'

Write-Host "[-] Copying files to $out_dir"
cd "$build_dir\ysoserial\bin\"

Rename-Item "Release" "ysoserial.net"
Copy-Item "ysoserial.net" -Destination "$out_dir" -Recurse -force

Write-Host "[-] Cleaning up"
if (Test-Path -Path $build_dir)
{
    cd c:\
    cmd /c "del /Q /F /S $build_dir > nul"
    cmd /c rmdir "$build_dir" /q /s
}
