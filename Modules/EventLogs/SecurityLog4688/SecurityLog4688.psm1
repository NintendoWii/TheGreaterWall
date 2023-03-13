function SecurityLog4688{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "SecurityLog4688"
            InstanceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            ProcessName= $null
            Processid= $null
            ParentProcessName= $null
            ParentProcessID= $null
            Commandline= $null
            ParentChildRelationship= $null
        }
    return $outputclass
    }   

    $output= @()
   
    $EventId4688 = Get-EventLog -LogName Security -After $(get-date).AddDays(-10) | where {$_.instanceid -eq "4688"}
    
    $Hostname= $env:COMPUTERNAME
    $operatingsystem= $(Get-WmiObject win32_operatingsystem).name.tostring().split('|')[0]
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId4688){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $Timewritten = $i.TimeWritten
        $ProcessName = $i.ReplacementStrings[5]
        $processid= [uint32]$($i.ReplacementStrings[4])
        $ParentProcessName = $i.ReplacementStrings[13]
        $parentprocessid= [uint32]($($I.ReplacementStrings[7])).tostring()
        $CommandLine = $i.ReplacementStrings[8]
        $parentchild= $processname + " - " + $ParentProcessName
        
        $results.Hostname= $Hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.InstanceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $Timewritten
        $results.ProcessName= $ProcessName
        $results.processid= $processid
        $results.ParentProcessName= $ParentProcessName
        $results.ParentProcessID= $parentprocessid
        $results.Commandline= $CommandLine
        $results.ParentChildRelationship= $parentchild
        $output += $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SecurityLog4688
