# some code taken from ie_com listener at https://github.com/EmpireProject/Empire
# thanks @harmj0y!
$ie_com = New-Object -ComObject InternetExplorer.Application
$ie_com.Silent  = $True
$ie_com.Visible = $False
$Headers = "Host: www.bing.com`r`n"
$ie_com.Navigate2("https://www.bing.com", 14, 0, $Null, $Headers)
while($ie_com.busy -eq $true) {
    Start-Sleep -Milliseconds 100
}
$html = $ie_com.document.GetType().InvokeMember('body', [System.Reflection.BindingFlags]::GetProperty, $Null, $ie_com.document, $Null).InnerHtml
Write-Host $html
