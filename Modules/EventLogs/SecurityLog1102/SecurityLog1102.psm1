Function SecurityLog1102{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            InstanceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            AccountResponsible= $null
        }
    return $outputclass
    }  

    $output= @()

    $EventId1102 = Get-EventLog -LogName Security | Where-Object {$_.EventID -eq "1102"}

    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    $hostname= $env:computername

    foreach($i in $EventId1102){
        $results= build-class
        $InstanceId=$i.InstanceId
        $Index=$i.Index
        $TimeGenerated=$i.TimeGenerated
        $TimeWritten=$i.TimeWritten
        $AccountResponsible=$i.ReplacementStrings[1]

        $results.Hostname= $hostname
        $results.DateCollected= $date
        $results.InstanceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.AccountResponsible= $AccountResponsible

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SecurityLog1102
