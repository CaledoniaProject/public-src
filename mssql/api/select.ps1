$ip   = "127.0.0.1"
$user = "XXX"
$pass = "XXX"

$conn = New-Object System.Data.SqlClient.SQLConnection("DATA SOURCE={0};USER ID={1};PASSWORD={2};" -f $ip, $user, $pass);
$conn.Open();

if ($conn.State -eq 'Open')
{
    $cmd = New-Object System.Data.SqlClient.SQLCommand("EXEC xp_cmdshell 'whoami';", $conn);
    $rdr = $cmd.ExecuteReader();

    $rs = @();
    while ($rdr.Read()) {
        $r = @{};
        for ($i = 0; $i -lt $rdr.FieldCount; $i++){
            $r[$rdr.GetName($i)] = $rdr.GetValue($i)
        }
        $rs += New-Object PSObject -Property $r 
    }

    $conn.Close();
    $rs
}
