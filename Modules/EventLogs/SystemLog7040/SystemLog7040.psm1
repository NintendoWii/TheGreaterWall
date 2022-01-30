function SystemLog7040{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Source= "SystemLog7040"
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            Service= $null
            OldStart= $null
            NewStart= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId7040 = Get-EventLog -LogName System | Where-Object {$_.EventID -eq "7040"}
    $hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId7040){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $Service = $i.ReplacementStrings[0]
        $PStart = $i.ReplacementStrings[1]
        $NStart = $i.ReplacementStrings[2]

        $results.hostname= $hostname
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.Service= $Service
        $results.OldStart= $old
        $results.NewStart= $new
        
        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SystemLog7040
