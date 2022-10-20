function EnumerateEventLogs{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Logname= $null
            ID= $null      
            UID= $null      
        }
    return $outputclass
    }  

    $start= get-date
    $all_logs= $(Get-WinEvent -listlog * | where {$_.recordcount -gt 0}).logname
    
    $output= @()
    $x= 1
    
    foreach ($log in $all_logs){   
        $event_ids= $(get-winevent -LogName $log -ErrorAction SilentlyContinue | % {$_.id}) | sort -Unique
        $datecollected= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
        foreach ($event_id in $event_ids){
            $results= build-class
            $results.Datecollected= $datecollected
            $results.Hostname= $env:computername
            $results.Logname= $log
            $results.ID= $event_id
            $results.UID= $($($log.tostring().tochararray() | % {[byte]$_}) | Measure-Object -Sum).sum.tostring() + "$event_id"
            $output+= $results | ConvertTo-Json
        }
        $x++
    }
    
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function EnumerateEventLogs
