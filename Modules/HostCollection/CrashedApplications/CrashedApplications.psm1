function CrashedApplications{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "CrashedApplications"
            Timegenerated= $null
            FaultingApplication= $null
            FaultingModule= $null
            ParentChild= $null
        }
    return $outputclass
    } 

    $output= @()

    $Hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
    $Faults = Get-EventLog -LogName Application -InstanceId 1000

    foreach ($f in $faults){
        $results= build-class

        $timestamp= $f.timegenerated
        $message= $f.message

        if ($message | select-string "Faulting"){
            $application= $f.ReplacementStrings[10]
            $module= $f.ReplacementStrings[11]
            $parentchild= "$application" + "-" + "$module"

            $results.Hostname= $Hostname
            $results.operatingsystem= $operatingsystem
            $results.DateCollected= $date
            $results.Timegenerated= $timestamp
            $results.FaultingApplication= $application
            $results.FaultingModule= $module
            $results.ParentChild= $parentchild

            $output+= $results | ConvertTo-Json
        }
    }

    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -function CrashedApplications
