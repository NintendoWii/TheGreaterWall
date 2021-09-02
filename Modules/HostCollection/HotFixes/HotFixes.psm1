function Hotfixes{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            ID= $null
            InstallDate= $null
        }
    return $outputclass
    }  

    $output= @()

    $hostname= $env:COMPUTERNAME
    $hotfix= Get-HotFix
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($h in $hotfix){
        $id= $h.hotfixid
        $installdate= $h.installedon

        $results= build-class
        $results.Hostname= $hostname
        $results.DateCollected= $date
        $results.ID= $id
        $results.InstallDate= $installdate

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function hotfixes
