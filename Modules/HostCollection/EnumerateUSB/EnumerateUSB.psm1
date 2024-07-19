function EnumerateUSB{
    function buildUsbRegistryObject{
            function build-class{
                $outputclass= [pscustomobject][ordered]@{
                IP= "null"
                Hostname= $null
                OperatingSystem= $null
                DateCollected= $null
                Source= "EnumerateUSB"
                Path= $null
                Driver= $null
                Service= $null
                Description= $null
                MFG= $null
            }
        return $outputclass
        }          
    
        $regobj= @()
        $hostname= $env:computername
        $os= Get-CimInstance -ClassName Win32_OperatingSystem   
        $operatingsystem= "$($os.caption) $($osversion)"
        $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

        $usb= (Get-childitem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\*").Name.Replace("HKEY_LOCAL_MACHINE","HKLM:")
        $usbstor= (Get-childitem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USBstor\*").Name.Replace("HKEY_LOCAL_MACHINE","HKLM:")
        $regkeys= @()
        $regkeys+= $usb
        $regkeys+= $usbstor

        foreach ($r in $regkeys){
            foreach ($i in $(Get-ChildItem -Recurse -path $r -ErrorAction SilentlyContinue | Get-ItemProperty)){
                $results= build-class

                $properties= $i | select *
                if ($properties | select-string "Driver"){
                    $path= $($properties.pspath).replace('Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE','HKLM:')
                    $path= $path-replace(',','-')
                    if (!$path){
                        $path= "NULL"
                    }
                    $driver= $properties.driver
                    $driver= $driver-replace(',','-')
                    if (!$driver){
                        $driver= "NULL"
                    }
                    $service= $properties.service
                    $service= $service-replace(',','-')
                    if (!$service){
                        $service= "NULL"
                    }
                    $description= $properties.DeviceDesc
                    $description= $description-replace(',','-')
                    if (!$description){
                        $description= "NULL"
                    }
                    $mfg= $properties.mfg
                    $mfg= $mfg-replace(',','-')
                    if (!$mfg){
                        $mfg= "NULL"
                    }
                    $results.hostname= $hostname
                    $results.operatingsystem= $operatingsystem
                    $results.DateCollected= $date
                    $results.path= $path
                    $results.Driver= $driver
                    $results.Service= $service
                    $results.Description= $description
                    $results.MFG= $mfg

                    $regobj+= $results | ConvertTo-Json
                }
            }
        }

        $regobj= $regobj | convertfrom-json

        foreach ($r in $regobj){
            if ($r.path | select-string 'USBSTOR'){
                $shortnames= $r.path-replace('USBSTOR','`')
                $shortnames= $shortnames.split('`')
                $shortnames= $shortnames | select-string -NotMatch "HKLM"
                $shortnames= $shortnames.tostring().split('\')
            }

            if ($r.path | select-string -notmatch 'USBSTOR'){
                $shortnames= $r.path-replace('USB','`')
                $shortnames= $shortnames.split('`')
                $shortnames= $shortnames | select-string -NotMatch "HKLM"
                $shortnames= $shortnames.tostring().split('\')
            }           
            $shortnames= $shortnames | where {$_} | % {$_.tostring()}
            $x= 1
            foreach ($s in $shortnames){
                Add-Member -NotePropertyName "shortname$x" -NotePropertyValue $s -InputObject $r
                $x++
            }
        }
        return $regobj
    }


    function buildEventlog20001Object{
        function build-class{
            $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Name= $null
            EventID= $null
            UserName= $null
            TimeGenerated= $null
            Timewritten= $null
            Status= $null
        }
        return $outputclass
        } 
        
        $logobj= @()

        $SystemLog20001= (Get-EventLog -LogName System | Where-Object {$_.EventID -eq "20001"})
        $hostname= $env:COMPUTERNAME
        $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

        foreach($S in $SystemLog20001){
            $results= build-class
            $name=$S.ReplacementStrings[3]
            $EventId=$S.EventID
            $Username=$S.UserName
            $TimeGenerated=$S.TimeGenerated
            $Timewritten=$S.TimeWritten
            $Status=$S.ReplacementStrings[8]

            $results.Hostname= $hostname
            $results.DateCollected= $date
            $results.Name= $name
            $results.EventID= $EventId
            $results.UserName= $Username
            $results.TimeGenerated= $TimeGenerated
            $results.Timewritten= $Timewritten
            $results.Status= $Status

            $logobj+= $results | ConvertTo-Json
            }
        $logobj= $logobj | ConvertFrom-Json

        return $logobj
    }


    function CompareRegtoLogs ($regobj,$logobj){
        $inlogs= @()
        $notinlogs= @()

        foreach ($r in $regobj){
            $shortnames= $($r | gm).name | select-string "Shortname"

            foreach ($s in $shortnames){
                $query= $r.$s

                if ($logobj.name | select-string $query){
                    $inlogs+= $query
                }

                if (!$($logobj.name | select-string $query)){
                    $notinlogs+= $query
                }
            }
        }
        $comparison= Compare-Object $inlogs $notinlogs
    $comparison

    }

    function BuildFinalOutput($comparison,$regobj,$logobj){
        function build-class{
            $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Path= $null
            Driver= $null
            Service= $null
            Description= $null
            MFG= $null
            Name= $null
            EventID= $null
            UserName= $null
            TimeGenerated= $null
            Timewritten= $null
            Status= $null
            LogCorrelation= $null
            }
            return $outputclass
        }          
            
        $finaloutput= @()

        $hostname= $env:COMPUTERNAME
        $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
        $inlogs= $($comparison | where {$_.sideindicator -eq "<="}).inputobject | sort -Unique
        $notinlogs= $($comparison | where {$_.sideindicator -eq "=>"}).inputobject | sort -Unique


        foreach ($i in $inlogs){
            $manipulate= $logobj | where {$_.name -like "*$i*"}
            $addfromreg= $regobj | select * | where {$_ -like "*$i*"}

            foreach ($m in $manipulate){

                foreach ($a in $addfromreg){
                    $results= build-class
                    
                    $results.hostname= $hostname
                    $results.DateCollected= $date
                    $results.path= $($a.path)
                    $results.Driver= $($a.driver)
                    $results.Service= $($a.service)
                    $results.Description= $($a.description)
                    $results.MFG= $($a.mfg)
                    $results.name= $($m.name)
                    $results.EventID= $($m.eventid)
                    $results.UserName= $($m.username)
                    $results.TimeGenerated= $($m.timegenerated)
                    $results.Timewritten= $($m.timewritten)
                    $results.status= $($m.status)
                    $results.LogCorrelation= "True"
                    
                    $finaloutput+= $results | ConvertTo-Json
                }
            }
        }

        foreach ($i in $notinlogs){
            $reg= $regobj | select * | where {$_ -like "*$i*"}

            foreach ($r in $reg){
                $results= build-class

                $results.hostname= $hostname
                $results.DateCollected= $date
                $results.path= $($r.path)
                $results.Driver= $($r.driver)
                $results.Service= $($r.service)
                $results.Description= $($r.description)
                $results.MFG= $($r.mfg)
                $results.name= "NULL"
                $results.EventID= "NULL"
                $results.UserName= "NULL"
                $results.TimeGenerated= "NULL"
                $results.Timewritten= "NULL"
                $results.status= "NULL"
                $results.LogCorrelation= "False"
                
                $finaloutput+= $results | ConvertTo-Json
            }
        }
    $finaloutput
    }

    $regobj= buildUsbRegistryObject
    $logobj= buildEventlog20001Object
    $comparison= CompareRegtoLogs $regobj $logobj
    $finaloutput= BuildFinalOutput $comparison $regobj $logobj

    $finaloutput= $finaloutput | ConvertFrom-Json
    $finaloutput= $finaloutput | where {$_.path -notlike "*device parameters*"}    
    $finaloutput= $finaloutput | ConvertTo-Csv -NoTypeInformation
    $finaloutput

}

Export-ModuleMember -Function enumerateusb







