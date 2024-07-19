function WindowsFirewall{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            RuleName= $null
            Enabled= $null
            Direction= $null
            Profiles= $null
            Grouping= $null
            Localip= $null
            Remoteip= $null
            Protocol= $null
            Localport= $null
            Remoteport= $null
            EdgeTraversal= $null
            Action= $null
            Source= "WindowsFirewall" 
        }
        return $outputclass
    }   

    $output= @()

    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""


    ###portProxy Rules
    $portproxyrules= @()
    $portproxy= $(netsh interface portproxy show all)
    $portproxyv4= $portproxy | select-string '\.'
    $portproxyv6= $portproxy | select-string '\:' | where {$_ -notlike "* on *"}
    $portproxyrules+= $portproxyv4
    $portproxyrules+= $portproxyv6

    if ($portproxyrules){
        foreach ($p in $portproxyrules){
            $p= $p.tostring().split(' ') | where {$_}

            $results= build-class

            $results.Operatingsystem= $operatingsystem
            $results.hostname= $hostname
            $results.DateCollected= $date
            $results.RuleName= 'null'
            $results.Enabled= 'Yes'
            $results.Direction= 'null'
            $results.Profiles= 'null'
            $results.Grouping= 'null'
            $results.Localip= $p[0]
            $results.Remoteip= $p[2]
            $results.Protocol= 'null'
            $results.Localport= $p[1]
            $results.Remoteport= $p[3]
            $results.EdgeTraversal= 'null'
            $results.Action= 'Forward'

            $output+= $results | ConvertTo-Json
        }
    }

    #Firewall Rules
    $fw= netsh advfirewall firewall show rule name=all profile=any

    $line_numbers= $($fw | sls "Rule Name:").linenumber    
    $x= 0

    while ($x -le $line_numbers.count){
        $start= $line_numbers[$x] - 1
        $end= $line_numbers[$($x+1)] - 2

        if ($start -lt 0 -or $end -lt 0){
            $x++
            continue
        }

        $record= $fw[$start..$end]

        $results= build-class
        
        ###RuleName
        try{
            $rulename= $($record | select-string "Rule Name:").tostring()
        }
        catch{}
        
    
        if (!$rulename){
            $rulename= 'null'                       
        }
    
        if ($rulename -and $rulename -ne 'null'){
            try{
                $rulename= $rulename.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$rulename){
                $rulename= 'null'
            }
        } 
    
        ###Enabled
        try{
            $enabled= $($record | select-string "Enabled:").tostring()
        }
        catch{}
        
        if (!$enabled){
            $enabled= 'null'
        }
    
        if ($enabled -and $enabled -ne 'null'){
            try{
                $enabled= $enabled.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$enabled){
                $enabled= 'null'
            }
        }
    
        ###Direction
        try{
            $direction= $($record | select-string "Direction:").tostring()
        }
        catch{}
        
        if (!$direction){
            $direction= 'null'
        }
    
        if ($direction -and $direction -ne 'null'){
            try{
                $direction= $direction.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$direction){
                $direction= 'null'
            }
        }
        
        ###Profiles
        try{
            $profiles= $($record | select-string "Profiles:").tostring()
        }
        catch{}
        
        if (!$profiles){
            $profiles= 'null'
        }
    
        if ($profiles -and $profiles -ne 'null'){
            try{
                $profiles= $profiles.split(':')[1].trimstart().replace(',','-')
            }
            catch{}
    
            if (!$profiles){
                $profiles= 'null'
            }
        } 
       
        ###Grouping
        try{
            $grouping= $($record | select-string "Grouping:").tostring()
        }
        catch{}
       
        if (!$grouping){
            $grouping= 'null'
        }
    
        if ($grouping -and $grouping -ne 'null'){
            try{
                $grouping= $grouping.split(':')[1].trimstart()
            }
            catch{}
            
            if (!$grouping){
                $grouping= 'null'
            }
        }
    
        ###LocalIP
        try{
            $localip= $($record | select-string "LocalIP:").tostring()
        }
        catch{}
       
        if (!$localip){
            $localip= 'null'
        }
    
        if ($localip -and $localip -ne 'null'){
            try{
                $localip= $localip.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$localip){
                $localip= 'null'
            }
        }
    
        ###RemoteIP
        try{
            $remoteip= $($record | select-string "RemoteIP:").tostring()
        }
        catch{}
           
        if (!$remoteip){
            $remoteip= 'null'
        }
    
        if ($remoteip -and $remoteip -ne 'null'){
            try{
                $remoteip= $remoteip.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$remoteip){
                $remoteip= 'null'
            }
        }
    
        ###Protocol
        try{
            $protocol= $($record | select-string "Protocol:").tostring()
        }
        catch{}
        
        if (!$protocol){
            $protocol= 'null'
        }
    
        if ($protocol -and $protocol -ne 'null'){
            try{
                $protocol= $protocol.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$protocol){
                $protocol= 'null'
            }
        } 
    
        ###LocalPort
        try{
            $localport= $($record | select-string "LocalPort:").tostring()
        }
        catch{}
        
        if (!$localport){
            $localport= 'null'
        }
    
        if ($localport -and $localport -ne 'null'){
            try{
                $localport= $localport.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$localport){
                $localport= 'null'
            }
        } 
    
        ###RemotePort
        try{
            $remoteport= $($record | select-string "RemotePort:").tostring()
        }
        catch{}
        
        if (!$remoteport){
            $remoteport= 'null'
        }
    
        if ($remoteport -and $remoteport -ne 'null'){
            try{
                $remoteport= $remoteport.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$remoteport){
                $remoteport= 'null'
            }
        }
    
        ###Edge Traversal
        try{
            $edgetraversal= $($record | select-string "Edge traversal:").tostring()
        }
        catch{}
        
        if (!$edgetraversal){
            $edgetraversal= 'null'
        }
    
        if ($edgetraversal -and $edgetraversal -ne 'null'){
            try{
                $edgetraversal= $edgetraversal.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$edgetraversal){
                $edgetraversal= 'null'
            }
        }
    
        ###Action
        try{
            $action= $($record | select-string "Action:").tostring()
        }
        catch{}
        
        if (!$action){
            $action= 'null'
        }
    
        if ($action -and $action -ne 'null'){
            try{
                $action= $action.split(':')[1].trimstart()
            }
            catch{}
    
            if (!$action){
                $action= 'null'
            }
        }
    
        #Build Results Obj
        $results.Operatingsystem= $operatingsystem
        $results.hostname= $hostname
        $results.DateCollected= $date
        $results.RuleName= $rulename
        $results.Enabled= $enabled
        $results.Direction= $direction
        $results.Profiles= $profiles
        $results.Grouping= $grouping
        $results.Localip= $localip
        $results.Remoteip= $remoteip
        $results.Protocol= $protocol
        $results.Localport= $localport
        $results.Remoteport= $remoteport
        $results.EdgeTraversal= $edgetraversal
        $results.Action= $action
        
        $output+= $results | ConvertTo-Json

        $x++
    }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function WindowsFirewall
