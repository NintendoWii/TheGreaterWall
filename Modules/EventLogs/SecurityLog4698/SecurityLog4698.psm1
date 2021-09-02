function SecurityLog4698{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            User= $null
            TaskName= $null
            MessageHash= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId4698 = Get-EventLog -LogName Security | Where-Object {$_.EventID -eq "4698"}
    $hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId4698){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $User = $i.ReplacementStrings[1]
        $Task = $i.ReplacementStrings[4]
        $Content = $i.ReplacementStrings[5] -replace '\s+',''
        $Content = [byte[]][char[]]$Content
        $jhash = ""
        $Content | foreach {$jhash = $jhash + $_}

        $results.Hostname= $hostname
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.User= $User
        $results.TaskName= $Task
        $results.messagehash= $jhash

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation\
}

Export-ModuleMember -Function SecurityLog4698
