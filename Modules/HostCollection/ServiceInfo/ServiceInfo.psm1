function ServiceInfo{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Source= "ServiceInfo"
            State= $null
            startmode= $null
            Servicename= $null
            pathname= $null
            processid= $null
            processname= $null
            parentprocessid= $null
            parentprocessname= $null
        }
    return $outputclass
    }          

    $output= @()

    $Hostname= $env:COMPUTERNAME
    $processes= Get-WmiObject win32_process
    $services= Get-WmiObject win32_Service
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
    
    foreach ($s in $services){
        $results= build-class
        $results.hostname= $hostname
        $results.DateCollected= $date
        $results.state= $s.state
        $results.startmode= $s.startmode
        $results.servicename= $s.name
        $results.pathname= $s.pathname
        $results.processid= $s.processid
        $processenum= $processes | where {$_.processid -eq $processid}
        $results.processname= $processenum.name
        $results.parentprocessid= $processenum.parentprocessid
        $parentpath= $($processes | where {$_.processid -eq $parentpid}).path

        if (!$parentpath){
            $parentpath= "NULL"
        }

        $results.parentprocessname= $parentpath

        $output+= $results | convertto-json
    }
    $output= $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
    $output
}

Export-ModuleMember -Function ServiceInfo 
