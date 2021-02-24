# 遇到错误退出
$ErrorActionPreference = "Stop"

# 设置允许 TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName System.IO.Compression.FileSystem

$desktop   = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$build_dir = $env:temp + "\mimikatz-master"
$zip_path  = $env:temp + "\mimikatz-master.zip"
$out_dir   = $desktop + "\release"

Write-Host "[-] Creating release folder"
New-Item -ItemType Directory -Force -Path $out_dir | Out-Null

Write-Host "[-] Downloading from github"
$web = New-Object Net.Webclient;
$web.DownloadFile("https://github.com/gentilkiwi/mimikatz/archive/master.zip", $zip_path);

# 解压缩
Write-Host "[-] Expanding zip"
if (Test-Path -Path $build_dir)
{
    cmd /c "del /Q /F /S $build_dir > nul"
    cmd /c rmdir "$build_dir" /q /s
}

[System.IO.Compression.ZipFile]::ExtractToDirectory($zip_path, "$build_dir\..")
Remove-Item -Path $zip_path

# 修正编译脚本
Write-Host "[-] Correcting vcxproj files"
Get-ChildItem "$build_dir\*\*.vcxproj" | ForEach-Object -Process {
    Write-Host " - " $_
    (Get-Content $_) `
        -Replace '<PreprocessorDefinitions>', '<PreprocessorDefinitions>UNICODE;' `
        -Replace '<PropertyGroup Label="Configuration">', '<PropertyGroup Label="Configuration"><SpectreMitigation>false</SpectreMitigation>' `
        -Replace '<TreatWarningAsError>true</TreatWarningAsError>', '<TreatWarningAsError>false</TreatWarningAsError>' | Set-Content $_
}

# 开始编译
Write-Host "[-] Start compilation"
cd $build_dir

cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars32.bat" && msbuild /target:mimikatz:Rebuild;mimilib:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v142'
cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat" && msbuild /target:mimikatz:Rebuild;mimilib:Rebuild /p:Configuration=Release /p:Platform=x64 /p:PlatformToolset=v142'

Write-Host "[-] Copying files to $out_dir"
Copy-Item "$build_dir\Win32\mimikatz.exe" -Destination "$out_dir\mimikatz32.exe"
Copy-Item "$build_dir\x64\mimikatz.exe" -Destination "$out_dir\mimikatz64.exe"

Copy-Item "$build_dir\Win32\mimilib.dll" -Destination "$out_dir\mimilib32.dll"
Copy-Item "$build_dir\x64\mimilib.dll" -Destination "$out_dir\mimilib64.dll"

Write-Host "[-] Cleaning up"
if (Test-Path -Path $build_dir)
{
    cd c:\
    cmd /c "del /Q /F /S $build_dir > nul"
    cmd /c rmdir "$build_dir" /q /s
}
