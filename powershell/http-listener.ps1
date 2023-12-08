[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null;

$listener = New-Object System.Net.HttpListener;
$listener.Prefixes.Add("http://*:8888/");
$listener.Start();

while ($listener.IsListening)
{
    $context    = $listener.GetContext();
    $requestUrl = $context.Request.Url;
    $response   = $context.Response;
    $localPath  = $requestUrl.LocalPath;

    Write-Host ("{0} {1}" -f $context.Request.httpmethod, $requestUrl.LocalPath)

    $content = "test from http listener";
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content);
    $response.ContentLength64 = $buffer.Length;
    $response.OutputStream.Write($buffer, 0, $buffer.Length);

    $response.Close();
    $responseStatus = $response.StatusCode;
}