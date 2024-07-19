function securityLog4624{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "SecurityLog4624"
            InstanceId= $null
            Index= $null
            TimeGenerated= $null
            RelativeTime= $null
            TimeWritten= $null
            AccountName= $null
            ProcessName= $null
            LogonProcess= $null
            LogonType= $null
            SourceIPAddress= $null
            SourcePort= $null
        }
    return $outputclass
    }  

    $output= @()

    $EventID_4624 = Get-EventLog -LogName Security | Where-Object -FilterScript {$_.EventID -eq "4624"}
    
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    Foreach($i in $EventID_4624){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $relativetime= $i.TimeGenerated.hour
        $TimeWritten = $i.TimeWritten
        $AccountName = $i.ReplacementStrings[1]
        $ProcessName = $i.ReplacementStrings[17]
        $LogonProcess = $i.ReplacementStrings[9]
        $LogonType = $i.ReplacementStrings[8]
        $SourceIpAddress = $i.ReplacementStrings[18]
        $SourcePort = $i.ReplacementStrings[19]

        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.InstanceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.RelativeTime= $relativetime
        $results.TimeWritten= $TimeWritten
        $results.AccountName= $AccountName
        $results.ProcessName= $ProcessName
        $results.LogonProcess= $LogonProcess
        $results.LogonType= $LogonType
        $results.SourceIPAddress= $SourceIpAddress
        $results.SourcePort= $SourcePort

        $output+= $results | ConvertTo-Json
    }
        $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function securityLog4624
