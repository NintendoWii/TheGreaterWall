function Hotfixes{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "Hotfixes"
            ID= $null
            InstallDate= $null
        }
    return $outputclass
    }  

    $output= @()

    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
    $hotfix= Get-HotFix
    
    foreach ($h in $hotfix){
        $id= $h.hotfixid
        $installdate= $h.installedon

        $results= build-class
        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.ID= $id
        $results.InstallDate= $installdate

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function hotfixes
