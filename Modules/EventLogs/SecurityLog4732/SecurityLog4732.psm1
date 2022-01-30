Function SecurityLog4732{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Source= "SecurityLog4732"
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
    
    $EventID_4732 = Get-EventLog -LogName Security | Where-Object -FilterScript {$_.EventID -eq "4732"}
    $hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    Foreach($i in $EventID_4732){
        $results= build-class

        $instanceid= $i.InstanceId
        $index= $i.Index
        $timegenerated= $i.TimeGenerated
        $timewritten= $i.TimeWritten
        $accountname= ($i).ReplacementStrings[6]
        $groupname= ($i).ReplacementStrings[2]
        $message= "A member was added to a security-enabled local group."

        $results.Hostname= $hostname
        $results.DateCollected= $date
        $results.InstanceID= $instanceid
        $results.Index= $index
        $results.TimeGenerated= $timegenerated
        $results.TimeWritten= $timewritten
        $results.AccountName= $accountname
        $results.GroupName= $groupname
        $results.message- $message

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function SecurityLog4732
