$results = Get-DnsServerZone | % {
    $zone = $_.zonename
    Get-DnsServerResourceRecord $zone | select @{
        n = 'ZoneName';
        e = {
            $zone
        }
    }, HostName, RecordType, @{
        n = 'RecordData';
        e = {
            if ($_.RecordData.IPv4Address.IPAddressToString) {
                $_.RecordData.IPv4Address.IPAddressToString
            } else {
                $_.RecordData.NameServer.ToUpper()
            }
        }
    }
}

$file = [Environment]::GetFolderPath("Desktop") + "\\dns.csv"
$results | Export-Csv -NoTypeInformation $file -Append