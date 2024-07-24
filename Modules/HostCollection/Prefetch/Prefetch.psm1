function Prefetch{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "Prefetch"
            Time= $null
            Name= $null
            Status= $null
        }
    return $outputclass
    }  

    $output= @()

    $PrefetchRegistry = (Get-Itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -name EnablePrefetcher).enableprefetcher
    $Prefetch = Get-ChildItem -Path C:\Windows\Prefetch | Sort-Object LastAccessTime
    
    $hostname= $env:COMPUTERNAME  
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($p in $Prefetch){
        $results= build-class

        $time= $p.lastaccesstime
        $name= $p.name

        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.time= $time
        $results.name= $name
        $results.Status= $PrefetchRegistry

        $output+= $results | ConvertTo-Json
    }

    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function prefetch
