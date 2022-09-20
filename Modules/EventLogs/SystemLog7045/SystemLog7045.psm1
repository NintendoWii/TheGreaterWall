function SystemLog7045{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "SystemLog7045"
            InstaceId= $null
            Index= $null
            TimeGenerated= $null
            TimeWritten= $null
            ServiceName= $null
            Path= $null
            ServiceType= $null
            StartType= $null
        }
    return $outputclass
    }          

    $output= @()

    $EventId7045 = Get-EventLog -LogName System | Where-Object {$_.EventID -eq "7045"}
    $hostname= $env:COMPUTERNAME
    $operatingsystem= $(Get-WmiObject win32_operatingsystem).name.tostring().split('|')[0]
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($i in $EventId7045){
        $results= build-class

        $InstanceId = $i.InstanceId
        $Index = $i.Index
        $TimeGenerated = $i.TimeGenerated
        $TimeWritten = $i.TimeWritten
        $Service = $i.ReplacementStrings[0]
        $Path = $i.ReplacementStrings[1]
        $ServiceType = $i.ReplacementStrings[2]
        $StartType = $i.ReplacementStrings[3]
        
        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.InstaceId= $InstanceId
        $results.Index= $Index
        $results.TimeGenerated= $TimeGenerated
        $results.TimeWritten= $TimeWritten
        $results.ServiceName= $Service
        $results.ServiceType= $ServiceType
        $results.StartType= $StartType

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
Export-ModuleMember -Function SystemLog7045
