function InstalledSoftware{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Name= $null
            Version= $null
            InstallLocation= $null
            InstallDate= $null
        }
    return $outputclass
    }  

    $output= @()

    $hostname= $env:COMPUTERNAME
    $product= Get-WmiObject win32_product
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    foreach ($p in $product){
        $results= build-class

        $name= $p.name
        if (!$name){
            $name= "NULL"
        }
        $version= $p.version
        if (!$version){
            $version= "NULL"
        }
        $installlocation= $p.installlocation
        if (!$installlocation){
            $installlocation= "NULL"
        }
        $installdate= $p.installdate
        if (!$date){
            $date= "NULL"
        }
        $results.hostname= $hostname
        $results.DateCollected= $date
        $results.name= $name
        $results.Version= $version
        $results.InstallLocation= $installlocation
        $results.InstallDate= $installdate

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function installedsoftware    
