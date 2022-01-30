Function SystemLog7000{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Source= "SystemLog7000"
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            Service= $null
            Reason= $null
        }
    return $outputclass
    }          

    $output= @()
        
	$EventId7000 = Get-EventLog -LogName System | Where-Object {$_.EventID -eq "7000"}
    $Hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

	foreach ($i in $EventId7000){
        $results= build-class

		$InstanceId = $i.InstanceId
		$Index = $i.Index
		$TimeGenerated = $i.TimeGenerated
		$TimeWritten = $i.TimeWritten
		$Service = $i.ReplacementStrings[0]
		$Reason = $i.ReplacementStrings[1]

        $results.Hostname= $Hostname
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.Service= $Service
        $results.Reason= $Reason

        $output+= $results | ConvertTo-Json
	}
	$output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SystemLog7000
