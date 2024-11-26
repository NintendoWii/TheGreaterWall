function Get-UnsignedLoadedModules {
    function Is-ModuleUnsigned($ModulePath) {
        # Load the module file as a byte array
        $bytes = [System.IO.File]::ReadAllBytes($ModulePath)
    
        # Check if the byte array contains the ASCII "MZ" signature at the beginning
        if ([System.Text.Encoding]::ASCII.GetString($bytes[0..1]) -eq "MZ") {
            # Get the offset of the PE header
            $offset = [System.BitConverter]::ToInt32($bytes[60..63], 0)
    
            # Check if the byte array contains the ASCII "PE" signature at the PE header offset
            if ([System.Text.Encoding]::ASCII.GetString($bytes[$offset..($offset+1)]) -eq "PE") {
                # Get the certificate directory entry offset
                $certOffset = [System.BitConverter]::ToInt32($bytes[($offset+120)..($offset+123)], 0)
    
                # Check if the certificate directory entry offset is non-zero
                if ($certOffset -ne 0) {
                    # The module is signed
                    return "True"
                }
            }
        }

        # The module is unsigned
        return "False"
    }

    function Build-Class {
        [PSCustomObject]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "ServiceInfo"
            ProcessName = $null
            ProcessID = $null
            ModuleName = $null
            FilePath = $null
            Signed = $null
        }
    }

    $output = @()
    $Hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    # Get all processes and their loaded modules
    $processes = Get-Process -IncludeUserName | Where-Object { $_.Modules }

    # Loop through each process and its loaded modules
    foreach ($process in $processes) {
        foreach ($module in $process.Modules) {
            # Check if the module is unsigned
            $isUnsigned = Is-ModuleUnsigned $module.FileName
            if ($isUnsigned) {
                # Build the output object
                $results = Build-Class
                $results.hostname= $hostname
                $results.operatingsystem= $operatingsystem
                $results.DateCollected= $date
                $results.ProcessName = $process.ProcessName
                $results.ProcessID = $process.Id
                $results.ModuleName = $module.ModuleName
                $results.FilePath = $module.FileName
                $results.Signed = $isUnsigned

                # Add the output object to the array
                $output += $results
            }
        }
    }

    # Output the results
    #$output | ConvertTo-Json -Depth 1
    $output | convertto-csv
}

Export-ModuleMember -Function Get-UnsignedLoadedModules
