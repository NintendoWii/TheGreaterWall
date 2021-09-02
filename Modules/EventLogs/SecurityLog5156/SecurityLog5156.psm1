function SecurityLog5156{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            Application= $null
            Direction= $null
            SourceAddress= $null
            SourcePort= $null
            DestinationAddress= $null
            DestinationPort= $null
            Protocol= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId5156 = Get-EventLog -LogName Security | Where-Object {$_.EventID -eq "5156"}
    $hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId5156){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $Application = $i.ReplacementStrings[1]
        $Direction = $i.ReplacementStrings[2]
        $SAdd = $i.ReplacementStrings[3]
        $SPort = $i.ReplacementStrings[4]
        $DAdd = $i.ReplacementStrings[5]
        $DPort = $i.ReplacementStrings[6]
        $Protocol = $i.ReplacementStrings[7]
        $P = $i.ReplacementStrings[0]

        $results.Hostname= $hostname
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.Application= $Application
        $results.Direction= $Direction
        $results.SourceAddress= $SAdd
        $results.SourcePort= $SPort
        $results.DestinationAddress= $DAdd
        $results.DestinationPort= $DPort
        $results.Protocol= $Protocol

        $output += $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function SecurityLog5156
