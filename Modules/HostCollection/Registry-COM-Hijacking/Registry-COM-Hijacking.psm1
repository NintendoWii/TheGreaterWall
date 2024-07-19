function Registry-COM-Hijacking{

    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= 'Null'
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Path= $null
            GenericPath= $null
            Key= $null
            Property= $null
            Value= $null
            Sha256FileHash = 'Null'
            IsAbandoned = "No"
            AbandonedFilepath= 'Null'
            Level= "Informational"
        }
        return $outputclass
    }  

    $output= @()
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    $hives= @()
    foreach ($u in $(get-childitem -Path Registry::HKEY_USERS)){
        
        if ($u.name -like "*_classes*"){
            if ($(get-childitem -Path Registry::$($u.name)\CLSID -ErrorAction SilentlyContinue)){
                $hives+= $(get-childitem -Path Registry::$($u.name)\CLSID -force -recurse).name
            }
        }
    
        if ($(get-childitem -Path Registry::$($u.name)\Software\Classes\CLSID -ErrorAction SilentlyContinue)){
            $hives+= $(get-childitem -Path Registry::$($u.name)\Software\Classes\CLSID -Force -Recurse).name
        }
    }
    
    $roothives= @('HKEY_LOCAL_MACHINE\Software\Classes\CLSID','HKEY_CURRENT_USER\Software\Classes\CLSID','HKEY_CLASSES_ROOT\CLSID')
    
    foreach ($r in $roothives){
        $hives+= $(get-childitem -Path Registry::$r -force -recurse -ErrorAction SilentlyContinue).name
    }
    
    foreach ($h in $hives){
        $props= get-itemproperty -path Registry::$h | out-string -stream | where {$_ -notlike "*PSPath*" -and $_ -notlike "PSParent*" -and $_ -notlike "PSChild*" -and $_ -notlike "PSprov*"} | where {$_}
        
        foreach ($p in $props){
            $results= build-class
            $results.Hostname = $hostname
            $results.DateCollected = $date
            $results.operatingsystem = $operatingsystem
            $results.Path = $h
            $results.GenericPath = $h
            $results.Key = $($h.split('\')[-1]).tostring().trimstart().trimend()
            $results.property = $($p-split(' : '))[0].tostring().trimstart().trimend()
            
            $val= $($p-split(' : '))[1].tostring().TrimStart().trimend()
            $val = $val.split(',')[0]
            
            $results.value = $val

            $pattern = '(?<=\\{)[\w-]+(?=})'
            $match= [regex]::Match($h, $pattern)
    
            if ($match.Success){
                $clsid= '{' + $($match.Value) + '}'

                #Replace the CLSID with generic placeholder to maintain integrity of data during grouping
                $results.GenericPath = $h-replace($clsid,"GENERIC_CLSID_PLACEHOLDER")
            }

            if ($val | select-string -Pattern "^[a-zA-Z]{1}\:\\"){

                #Check to see if if's rundll32, if so, grab the arg instead of rundll32
                if ($val | select-string -Pattern "\:\\Windows\\System32\\Rundll32\.exe"){
                    $val= $($val-split('Rundll32.exe').Trim() -replace '^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$')[1]
                }

                #Validate data using the most complex regex known to man...
                $val= $($val | select-string -Pattern "\b[A-Za-z]:\\(?:[^\\]+\\)*[^\\]+(?:\.[A-Za-z]{3,4})(?=\W|$)").Matches.value

                try{
                    $val= $val.Trim() -replace '^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'
                }

                Catch{}

                #If the value is still a filepath after all the regex validation, try to get the hash and check to see if it's abandoned.
                if ($val | select-string -Pattern "^[a-zA-Z]{1}\:\\"){
                    
                    if (get-item -path $val -ErrorAction SilentlyContinue){
                         $results.Sha256FileHash = $(Get-FileHash -path $val -Algorithm SHA256 -ErrorAction SilentlyContinue).hash                                                  
                    }

                    if (!$(get-item -path $val -ErrorAction SilentlyContinue)){
                        $results.IsAbandoned = 'Yes'
                        $results.AbandonedFilePath = $val
                    }                                
                }
            }            

            #Do basic checks to raise level from informational to warning.
            if ($val | Select-String "\.sct"){
                $results.level = "Warning"
            }

            if ($val | Select-String "scrobj\.dll"){
                $results.level = "Warning"
            } 
            
            if ($val -match '^([A-Za-z]:\\[^ ]+)$' -and $val -notlike "*\windows\system32\*"){
                $results.level = "Warning"
            }

            #Replace SIDS with generic placeholder to maintain integrity of data during grouping
            if ($h | select-string "HKEY_USERS"){
                $replacementstring= $h.split('\')[1]
                $results.genericpath = $h-replace($replacementstring,"GENERIC_USER_PLACEHOLDER")
            }
            
            $output+= $results | ConvertTo-Json               
        }
    }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}
Export-ModuleMember -Function Registry-Com-Hijacking
