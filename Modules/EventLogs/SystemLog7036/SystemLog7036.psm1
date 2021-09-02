function SystemLog7036{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            Device= $null
            StateEntered= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId7036 = Get-EventLog -LogName System | Where-Object {$_.EventID -eq "7036"}
    $hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId7036){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $Device = $i.ReplacementStrings[0]
        $State = $i.ReplacementStrings[1]

        $results.Hostname= $hostname
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.Device= $Device
        $results.StateEntered= $State
        
        $output+= $results | ConvertTo-Json
    }
	$output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SystemLog7036
