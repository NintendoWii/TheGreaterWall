function SecurityLog4657{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "SecurityLog4657"
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            User= $null
            ObjectChanged= $null
            Operation= $null
            Value= $null
            ValueType= $null
            PID= $null
        }
    return $outputclass
    } 

    $output= @()

    $EventId4657 = Get-EventLog -LogName Security | Where-Object {$_.EventID -eq "4657"}
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId4657){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $User = $i.ReplacementStrings[1]
        $Obj = $i.ReplacementStrings[4]
        $Op = $i.ReplacementStrings[7]
        $ValueType = $i.ReplacementStrings[10]
        $Value = $i.ReplacementStrings[11]
        $P = $i.ReplacementStrings[12]

        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.User= $User
        $results.ObjectChanged= $obj
        $results.Operation= $Op
        $results.Value= $Value
        $results.ValueType= $ValueType
        $results.PID= $P
        
        $output+= $results | convertto-json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function SecurityLog4657
