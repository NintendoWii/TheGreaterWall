function EnumerateEventLogs{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Logname= $null
            ID= $null
            Firstcreated= $null
            Lastcreated= $null
            RecordCount= $null      
            UID= $null                  
        }
    return $outputclass
    }  

    $start= get-date
    $all_logs= $(Get-WinEvent -listlog * | where {$_.recordcount -gt 0}).logname
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    
    $output= @()
    $x= 1
    
    foreach ($log in $all_logs){   
        $evt_log= $(get-winevent -LogName $log -ErrorAction SilentlyContinue)
        $event_ids= $($evt_log | % {$_.id})
        $stats= $event_ids| Group-Object | select count,name
        $event_ids= $event_ids | sort -Unique
        $datecollected= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
        foreach ($event_id in $event_ids){
            $createdtimes= $(get-winevent -FilterHashtable @{LogName=$log;ID=$event_id} -ErrorAction SilentlyContinue).timecreated
            $first= $createdtimes[0]
            $last= $createdtimes[$createdtimes.count -1]
            $results= build-class
            $results.Datecollected= $datecollected
            $results.Hostname= $env:computername
            $results.OperatingSystem= $operatingsystem
            $results.Logname= $log
            $results.ID= $event_id
            $results.firstcreated= "$($first.day)-$((Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($($first.month)))-$($first.year)-$($first.hour):" + "$($first.minute):" + "$($first.Second)"
            $results.lastcreated= "$($last.day)-$((Get-Culture).DateTimeFormat.GetAbbreviatedMonthName($($last.month)))-$($last.year)-$($last.hour):" + "$($last.minute):" + "$($last.Second)"
            $results.RecordCount= $($stats | where {$_.name -eq "$event_id"}).count
            $results.UID= $($($log.tostring().tochararray() | % {[byte]$_}) | Measure-Object -Sum).sum.tostring() + "$event_id"            
            $output+= $results | ConvertTo-Json
        }
        $x++
    }
    
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function EnumerateEventLogs
