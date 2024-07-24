Function ImageFileExecutionOptions{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
	    OperatingSystem= $null
            DateCollected= $null
            Source= "ImageFileExecuionOptions"
            Regpath= $null
            Key= $null
            Value= $null
            KeyVal= $null
        }
    return $outputclass
    }  
    
    $output= @()
        
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    
    $HKLM_FileExec = Get-ItemProperty -Path "HKLM:\\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\*" -ErrorAction SilentlyContinue
    $HKLM_SilentProcessExit = Get-ItemProperty -Path "HKLM:\\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SilentProcessExit\*" -ErrorAction SilentlyContinue
    $regkeys= @()
    $regkeys+= 'hklm_FileExec'
    $regkeys+= 'hklm_SilentProcessExit'

    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    foreach ($key in $regkeys){
        $results= build-class

        $content= get-variable -name $key
        $paths= $content.value.pspath

        foreach ($p in $paths){
            $obj= Get-Item -path $p
            $name= $obj.name.split('\')[-1]            
            $properties= $obj.property
            foreach ($prop in $properties){
                if ($prop -eq "reportingmode" -or $prop -eq "MonitorProcess" -or $prop -eq "globalflag" -or $prop -eq "debugger"){
                    $propertyvalue= Get-ItemProperty -path $p -Name $prop
                    $propertyvalue= $($propertyvalue | convertto-csv | convertfrom-csv).$prop
		            $keyval= "$prop" + "-" + "$propertyvalue"

                    $results.Hostname= $hostname
		    $results.operatingsystem= $operatingsystem
                    $results.DateCollected= $date
                    $results.Regpath= $p
                    $results.key= $prop
                    $results.Value= $propertyvalue
                    $results.KeyVal= $keyval

                    $output+= $results | convertto-json
                }
            }
        }
    }
        
    if (!$output){
        $results= build-class
        $results.IP= "null"
        $results.Hostname= $hostname
        $results.DateCollected= "null"
        $results.Source= "ImageFileExecuionOptions"
        $results.Regpath= "null"
        $results.Key= "null"
        $results.Value= "null"
        $results.KeyVal= "null"
        $output= $results | convertto-json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function ImageFileExecutionOptions
