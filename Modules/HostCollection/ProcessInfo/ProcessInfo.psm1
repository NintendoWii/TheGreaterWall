Function ProcessInfo{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "ProcessInfo"
            ProcessName= $null
            ProcessID= $null
            ParentProcessName= $null
            ParentProcessID= $null
            Path= $null
            CommandLine= $null
            StartTime= $null
            User= $null
            Sid= $null
            Domain= $null
            '(E)LocalIP'= $null
            '(E)LocalPort'= $null
            '(E)RemoteIP'= $null
            '(E)Remoteport'= $null
            '(L)LocalIP'= $null
            '(L)LocalPort'= $null
            '(L)RemoteIP'= $null
            '(L)Remoteport'= $null

        }
    return $outputclass
    } 

    $output= @()

    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $ErrorActionPreference="silentlycontinue"
    $ProcessList = Get-WmiObject -Class Win32_Process
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    Foreach ($Process in $ProcessList){
        $results= build-class
        $ParentProcess =  (Get-WmiObject -Class Win32_process | Where-Object {$_.Processid -eq $Process.ParentProcessId})
        $ParentProcessName= $ParentProcess.name
        $ParentProcessID= $ParentProcess.processid
        $SID = ($Process).getownersid().SID
        $User = ($Process).getowner().user
        $Domain = ($Process).getowner().Domain
        $path= $process.path

        Foreach ($establishedIP in (Get-NetTCPConnection | Where-Object {$_.OwningProcess -eq $Process.ProcessId -and $_.State -eq "Established"})){
            $elocalip= $establishedIP.localaddress
            $elocalport= $establishedIP.localport
            $eremoteip= $establishedIP.remoteaddress
            $eremoteport= $establishedIP.remoteport            
        } 
        
        Foreach ($establishedIP in (Get-NetTCPConnection | Where-Object {$_.OwningProcess -eq $Process.ProcessId -and $_.State -eq "Listen"})){
            $llocalip= $establishedIP.localaddress
            $llocalport= $establishedIP.localport
            $lremoteip= $establishedIP.remoteaddress
            $lremoteport= $establishedIP.remoteport
        } 
            
        $commandline= $Process.commandline
        
        if (!$commandline){
            $commandline= "NULL"
        }

        if (!$user){
            $user= "NULL"
        }

        if (!$sid){
            $sid= "NULL"
        }

        if (!$domain){
            $domain= "NULL"
        }

        if (!$path){
            $path= "NULL"
        }

        if (!$elocalip){
            $elocalip= "NULL"
        }

        if (!$elocalport){
            $elocalport= "NULL"
        }

        if (!$eremoteip){
            $eremoteip= "NULL"
        }

        if (!$eremoteport){
            $eremoteport= "NULL"
        }

        if (!$rlocalip){
            $rlocalip= "NULL"
        }

        if (!$rlocalport){
            $rlocalport= "NULL"
        }

        if (!$rremoteip){
            $rremoteip= "NULL"
        }

        if (!$rremoteport){
            $rremoteport= "NULL"
        }

        if (!$parentprocessname){
            $parentprocessname= "NULL"
        }

        if (!$parentprocessid){
            $parentprocessid= "NULL"
        }


    $results.hostname= $hostname
    $results.operatingsystem= $operatingsystem
    $results.datecollected= $date
    $results.processname= $($process.name)
    $results.ProcessID= $($process.processid)
    $results.ParentProcessName= $ParentProcessName
    $results.ParentProcessID= $ParentProcessID
    $results.Path= $path
    $results.CommandLine= $commandline
    $results.StartTime= $($process.converttodatetime($process.creationdate).date).tostring()
    $results.user= $User
    $results.sid= $SID
    $results.domain= $Domain
    $results.'(E)LocalIP'= $elocalip
    $results.'(E)LocalPort'= $elocalport
    $results.'(E)RemoteIP'= $eremoteip
    $results.'(E)Remoteport'= $eremoteport
    $results.'(L)LocalIP'= $llocalip
    $results.'(L)LocalPort'= $llocalport
    $results.'(L)RemoteIP'= $lremoteip
    $results.'(L)Remoteport'= $lremoteport

    $output+= $results | convertto-json
    }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function ProcessInfo

