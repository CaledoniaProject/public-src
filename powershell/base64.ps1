$data = Get-Content "test.ps1"
$enc  = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($data))

Write-Host $enc
Write-Host [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($enc))
