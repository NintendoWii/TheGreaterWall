function SecurityLog4719{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
	    OperatingSystem= $null
            DateCollected= $null
            Source= "SecurityLog4719"
            InstaceID= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            User= $null
            Category= $null
            Subcategory= $null
            AuditPolicyChange= $null
            TotalCategory= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId4719 = Get-EventLog -LogName Security | Where-Object {$_.EventID -eq "4719"}
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId4719){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $User = $i.ReplacementStrings[1]
        $Cat = $i.ReplacementStrings[4]
        $SubCat = $i.ReplacementStrings[5]	
	    $totalcategory= $cat + " - " + $subcat
        $AuditPolChange = $i.ReplacementStrings[7] -replace '\s+',''

        $results.hostname= $hostname
	$results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.InstaceID= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.User= $User
        $results.Category= $Cat
        $results.Subcategory= $subcat
        $results.AuditPolicyChange= $AuditPolChange
        $results.TotalCategory= $totalcategory

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function SecurityLog4719
