# 遇到错误退出
$ErrorActionPreference = "Stop"

# 设置允许 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName System.IO.Compression.FileSystem

$desktop   = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$build_dir = $env:temp + "\uacme-master"
$zip_path  = $env:temp + "\uacme-master.zip"
$out_dir   = $desktop + "\release"

Write-Host "[-] Creating release folder"
New-Item -ItemType Directory -Force -Path $out_dir | Out-Null

Write-Host "[-] Downloading from github"
$web = New-Object Net.Webclient;
$web.DownloadFile("https://github.com/hfiref0x/uacme/archive/master.zip", $zip_path);

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
cd $build_dir\\Source
cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat" && msbuild uacme.sln /t:Build /p:Configuration=Release;Platform=x64 /p:PostBuildEventUseInBuild=false'
cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars32.bat" && msbuild uacme.sln /t:Build /p:Configuration=Release;Platform=Win32 /p:PostBuildEventUseInBuild=false'

Write-Host "[-] Copying files to $out_dir"
Copy-Item "$build_dir\Source\Akagi\output\x64\Release\Akagi64.exe" -Destination "$out_dir\uacme64.exe"
Copy-Item "$build_dir\Source\Akagi\output\Win32\Release\Akagi32.exe" -Destination "$out_dir\uacme32.exe"

Write-Host "[-] Cleaning up"
if (Test-Path -Path $build_dir)
{
    cd c:\
    cmd /c "del /Q /F /S $build_dir > nul"
    cmd /c rmdir "$build_dir" /q /s
}
