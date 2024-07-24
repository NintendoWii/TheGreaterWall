Function SecurityLog4756{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "SecurityLog4756"
            InstanceID= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            AccountName= $null
            GroupName= $null
            Message= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventID_4756 = Get-EventLog -LogName Security | Where-Object -FilterScript {$_.EventID -eq "4756"}
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    Foreach($i in $EventID_4756){
        $results= build-class

        $hostname= $env:COMPUTERNAME
        $dateCollected= $date
        $instanceID= $i.InstanceId
        $index= $i.Index
        $timeGenerated= $i.TimeGenerated
        $timeWritten= $i.TimeWritten
        $accountName= $i.ReplacementStrings[6]
        $groupName= $i.ReplacementStrings[2]
        $message= "A member was added to a security-enabled Universal group."

        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.instanceID= $instanceID
        $results.Index= $index
        $results.TimeGenerated= $timeGenerated
        $results.TimeWritten= $timeWritten
        $results.AccountName= $accountName
        $results.GroupName= $groupName
        $results.Message= $message

        $output+= $results | ConvertTo-Json
        }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function SecurityLog-4756
