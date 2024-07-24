function SystemLog7036{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
	    OperatingSystem= $null
            DateCollected= $null
            Source= "SystemLog7036"
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
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
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
	$results.operatingsystem= $operatingsystem
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
