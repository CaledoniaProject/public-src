$Username   = "tt"
$Password   = "tt"
$LocalFile  = "C:\windows\system32\calc.exe"
$RemoteFile = "ftp://xx.xx.xx.xx/calc.exe"

# Create a FTPWebRequest
$FTPRequest             = [System.Net.FtpWebRequest]::Create("$RemoteFile")
$FTPRequest.Method      = [System.Net.WebRequestMethods+Ftp]::UploadFile
$FTPRequest.Credentials = new-object System.Net.NetworkCredential($Username, $Password)
$FTPRequest.UseBinary   = $true
$FTPRequest.UsePassive  = $true

# Read the File for Upload
$FileContent = gc -en byte $LocalFile
$FTPRequest.ContentLength = $FileContent.Length

# Get Stream Request by bytes
$Run = $FTPRequest.GetRequestStream()
$Run.Write($FileContent, 0, $FileContent.Length)

# Cleanup
$Run.Close()

