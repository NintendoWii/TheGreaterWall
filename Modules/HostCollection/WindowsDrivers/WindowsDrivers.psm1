function WindowsDrivers{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Drivers= $null
            OriginalFileName= $null
            Hash= $null
            Inbox= $null
            ClassName= $null
            BootCritical= $null
            ProviderName= $null
            DateofDriver= $null
            Version= $null 
            Source= "WindowsDrivers" 
        }
        return $outputclass
    }   
    
    $output= @() 
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    $WindowsDrivers = Get-WindowsDriver -Online 

    foreach ($i in $WindowsDrivers){ 
        $results= build-class 
        $Hash=Get-FileHash -Path $i.OriginalFileName -Algorithm SHA256       
        $Drivers=$i.driver
        $OriginalFileName=$i.OriginalFileName
        $Hash=$Hash.Hash
        $Inbox=$i.Inbox
        $ClassName=$i.ClassName
        $BootCritical=$i.BootCritical
        $ProviderName=$i.ProviderName
        $DateofDriver=$i.Date
        $version=$i.Version

        $results.Hostname= $hostname
        $results.OperatingSystem=$operatingsystem
        $results.DateCollected=$date
        $results.drivers=$Drivers
        $results.OriginalFileName=$OriginalFileName
        $results.Hash=$Hash
        $results.Inbox=$Inbox
        $results.ClassName=$ClassName
        $results.BootCritical=$BootCritical
        $results.ProviderName=$ProviderName
        $results.DateofDriver=$DateofDriver
        $results.Version=$version 
        
        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}
Export-ModuleMember -Function WindowsDrivers
