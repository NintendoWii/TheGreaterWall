function SystemLog7034{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            Service= $null
            NumberOfTimes= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId7034 = Get-EventLog -LogName System | Where-Object {$_.EventID -eq "7034"}
    $Hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId7034){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $Service = $i.ReplacementStrings[0]
        $NumTimes = $i.ReplacementStrings[1]

        $results.Hostname=$Hostname
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.Service= $Service
        $results.NumberOfTimes= $NumTimes

        $output+= $results | ConvertTo-Json
    }
	$output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SystemLog7034
