function SecurityLog4688{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            InstanceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            ProcessName= $null
            ParentProcessName= $null
            Commandline= $null
            ParentChildRelationship= $null
        }
    return $outputclass
    }   

    $output= @()
   
    $EventId4688 = Get-EventLog -LogName Security -After $(get-date).AddDays(-10) | where {$_.instanceid -eq "4688"}
    
    $Hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId4688){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $Timewritten = $i.TimeWritten
        $ProcessName = $i.ReplacementStrings[5]
        $ParentProcessName = $i.ReplacementStrings[13]
        $CommandLine = $i.ReplacementStrings[8]
        $parentchild= $processname + " - " + $ParentProcessName
        
        $results.Hostname= $Hostname
        $results.DateCollected= $date
        $results.InstanceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $Timewritten
        $results.ProcessName= $ProcessName
        $results.ParentProcessName= $ParentProcessName
        $results.Commandline= $CommandLine
        $results.ParentChildRelationship= $parentchild
        $output += $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SecurityLog4688
