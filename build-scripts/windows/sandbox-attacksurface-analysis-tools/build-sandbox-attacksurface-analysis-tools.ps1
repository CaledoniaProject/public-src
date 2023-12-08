# 遇到错误退出
$ErrorActionPreference = "Stop"

# 设置允许 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName System.IO.Compression.FileSystem

$desktop   = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$build_dir = $env:temp + "\sandbox-attacksurface-analysis-tools-master"
$zip_path  = $env:temp + "\sandbox-attacksurface-analysis-tools-master.zip"
$out_dir   = $desktop + "\release"

Write-Host "[-] Creating release folder"
New-Item -ItemType Directory -Force -Path $out_dir | Out-Null

Write-Host "[-] Downloading from github"
$web = New-Object Net.Webclient;
$web.DownloadFile("https://github.com/googleprojectzero/sandbox-attacksurface-analysis-tools/archive/master.zip", $zip_path);

# 解压缩
Write-Host "[-] Expanding zip"
if (Test-Path -Path $build_dir)
{
    cmd /c "del /s /Q /F /S $build_dir > nul"
    cmd /c rmdir "$build_dir" /q /s
}

[System.IO.Compression.ZipFile]::ExtractToDirectory($zip_path, "$build_dir\..")
Remove-Item -Path $zip_path

# 开始编译
Write-Host "[-] Start compilation"
cd $build_dir

# 修正 TargetFrameworkVersion
Get-ChildItem "$build_dir\*\*.vcxproj" | ForEach-Object -Process {
    Write-Host " - " $_
    (Get-Content $_) `
        -Replace '<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>', '<TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>' `
        -Replace '<TargetFrameworkVersion>v4.6</TargetFrameworkVersion>', '<TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>' | Set-Content $_
}

# 恢复 nuget 包
Write-Host "[-] Restoring nuget packages"
cmd /c c:\windows\nuget.exe restore sandbox-attacksurface-analysis-tools.sln

cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat" && msbuild /p:Configuration=Release /p:Platform="Any CPU"'

Write-Host "[-] Copying files to $out_dir"
cd "$build_dir\bin"

Copy-Item "Release" -Destination "$out_dir\sandbox-attacksurface-analysis-tools" -Recurse -force

Write-Host "[-] Cleaning up"
if (Test-Path -Path $build_dir)
{
    cd c:\
    cmd /c "del /s /Q /F /S $build_dir >nul"
    cmd /c rmdir "$build_dir" /q /s
}

