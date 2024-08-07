function SecurityLog4724{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "SecurityLog4724"
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            TargetUserName= $null
            SubjectUserName= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId4724 = Get-EventLog -LogName Security | Where-Object {$_.EventID -eq "4724"}
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId4724){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $TargetUserName = $i.ReplacementStrings[0]
        $SubjectUserName = $i.ReplacementStrings[4]

        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.TargetUserName= $TargetUserName
        $results.SubjectUserName= $SubjectUserName

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
export-modulemember -function SecurityLog4724

