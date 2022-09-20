function AppCompatCache{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "AppCompatCache"
            CachePosition= $null
            LastModifiedTime= $null
            Path= $null
            RelativeEvent= $null
            RelativeName= $null
            Shortpath= $null

        }
        return $outputclass
    }  


    function ConvertFrom-ByteArray {    
            param (
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [Object]
            $CacheValue,
            
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $OSVersion,
            
            [Parameter()]
            [string]
            $OSArchitecture
        )
    
        $BinaryReader = New-Object IO.BinaryReader (New-Object IO.MemoryStream (,$CacheValue))
    
        $ASCIIEncoding = [Text.Encoding]::ASCII
        $UnicodeEncoding = [Text.Encoding]::Unicode
    
        switch ($OSVersion) {
            
            { $_ -like '10.*' } { # Windows 10
                
                $null = $BinaryReader.BaseStream.Seek(48, [IO.SeekOrigin]::Begin)
                
                # check for magic
                if ($ASCIIEncoding.GetString($BinaryReader.ReadBytes(4)) -ne '10ts') { 
                    $null = $BinaryReader.BaseStream.Seek(52, [IO.SeekOrigin]::Begin) # offset shifted in creators update
                    if ($ASCIIEncoding.GetString($BinaryReader.ReadBytes(4))  -ne '10ts') { throw 'Not Windows 10' }
                }
    
                do { # parse entries
                    $null = $BinaryReader.BaseStream.Seek(8, [IO.SeekOrigin]::Current) # padding between entries
                    
                    $Path = $UnicodeEncoding.GetString($BinaryReader.ReadBytes($BinaryReader.ReadUInt16()))
                    $LastModifiedTime = [DateTimeOffset]::FromFileTime($BinaryReader.ReadInt64()).DateTime
                    
                    $null = $BinaryReader.ReadBytes($BinaryReader.ReadInt32()) # skip some bytes
                    
                    $ObjectProperties = [ordered] @{
                        PSTypeName = 'CimSweep.AppCompatCacheEntry'
                        Path = $Path
                        LastModifiedTime = $LastModifiedTime.ToUniversalTime().ToString('o')
                    }
                    
                    if ($CacheValue.PSComputerName) { $ObjectProperties['PSComputerName'] = $CacheValue.PSComputerName }
                    [PSCustomObject]$ObjectProperties
    
                } until ($ASCIIEncoding.GetString($BinaryReader.ReadBytes(4)) -ne '10ts')
            }
    
            { $_ -like '6.3*' } { # Windows 8.1 / Server 2012 R2
    
                $null = $BinaryReader.BaseStream.Seek(128, [IO.SeekOrigin]::Begin)
    
                # check for magic
                if ($ASCIIEncoding.GetString($BinaryReader.ReadBytes(4)) -ne '10ts') { throw 'Not windows 8.1/2012r2' }
                
                do { # parse entries
                    $null = $BinaryReader.BaseStream.Seek(8, [IO.SeekOrigin]::Current) # padding & datasize
                    
                    $Path = $UnicodeEncoding.GetString($BinaryReader.ReadBytes($BinaryReader.ReadUInt16()))
    
                    $null = $BinaryReader.ReadBytes(10) # skip insertion/shim flags & padding
                    
                    $LastModifiedTime = [DateTimeOffset]::FromFileTime($BinaryReader.ReadInt64()).DateTime
                    
                    $null = $BinaryReader.ReadBytes($BinaryReader.ReadInt32()) # skip some bytes
                    
                    $ObjectProperties = [ordered] @{
                        PSTypeName = 'CimSweep.AppCompatCacheEntry'
                        Path = $Path
                        LastModifiedTime = $LastModifiedTime.ToUniversalTime().ToString('o')
                    }
                    
                    if ($CacheValue.PSComputerName) { $ObjectProperties['PSComputerName'] = $CacheValue.PSComputerName }
                    [PSCustomObject]$ObjectProperties
    
                } until ($ASCIIEncoding.GetString($BinaryReader.ReadBytes(4)) -ne '10ts')
            }
    
            { $_ -like '6.2*' } { # Windows 8.0 / Server 2012
    
                # check for magic
                $null = $BinaryReader.BaseStream.Seek(128, [IO.SeekOrigin]::Begin)
                if ($ASCIIEncoding.GetString($BinaryReader.ReadBytes(4)) -ne '00ts') { throw 'Not Windows 8/2012' }
    
                do { # parse entries
                    $null = $BinaryReader.BaseStream.Seek(8, [IO.SeekOrigin]::Current) # padding & datasize
                    
                    $Path = $UnicodeEncoding.GetString($BinaryReader.ReadBytes($BinaryReader.ReadUInt16()))
    
                    $null = $BinaryReader.BaseStream.Seek(10, [IO.SeekOrigin]::Current) # skip insertion/shim flags & padding
                    
                    $LastModifiedTime = [DateTimeOffset]::FromFileTime($BinaryReader.ReadInt64()).DateTime
                    
                    $null = $BinaryReader.ReadBytes($BinaryReader.ReadInt32()) # skip some bytes
                    
                    $ObjectProperties = [ordered] @{
                        PSTypeName = 'CimSweep.AppCompatCacheEntry'
                        Path = $Path
                        LastModifiedTime = $LastModifiedTime.ToUniversalTime().ToString('o')
                    }
                    
                    if ($CacheValue.PSComputerName) { $ObjectProperties['PSComputerName'] = $CacheValue.PSComputerName }
                    [PSCustomObject]$ObjectProperties
    
                } until ($ASCIIEncoding.GetString($BinaryReader.ReadBytes(4)) -ne '00ts')
            }
            
            { $_ -like '6.1*' } { # Windows 7 / Server 2008 R2
                
                # check for magic
                if ([BitConverter]::ToString($BinaryReader.ReadBytes(4)[3..0]) -ne 'BA-DC-0F-EE') { throw 'Not Windows 7/2008R2'}
                
                $NumberOfEntries = $BinaryReader.ReadInt32()
    
                $null = $BinaryReader.BaseStream.Seek(128, [IO.SeekOrigin]::Begin) # skip padding
    
                if ($OSArchitecture -eq '32-bit') {
                    
                    do {
                        $EntryPosition++
                        
                        $PathSize = $BinaryReader.ReadUInt16()
                        
                        $null = $BinaryReader.ReadUInt16() # MaxPathSize
                        
                        $PathOffset = $BinaryReader.ReadInt32()
                        
                        $LastModifiedTime = [DateTimeOffset]::FromFileTime($BinaryReader.ReadInt64()).DateTime
                        
                        $null = $BinaryReader.BaseStream.Seek(16, [IO.SeekOrigin]::Current)
                        
                        $Position = $BinaryReader.BaseStream.Position
                        
                        $null = $BinaryReader.BaseStream.Seek($PathOffset, [IO.SeekOrigin]::Begin)
                        
                        $Path = $UnicodeEncoding.GetString($BinaryReader.ReadBytes($PathSize))
    
                        $null = $BinaryReader.BaseStream.Seek($Position, [IO.SeekOrigin]::Begin)
                        
                        $ObjectProperties = [ordered] @{
                            PSTypeName = 'CimSweep.AppCompatCacheEntry'
                            Path = $Path
                            LastModifiedTime = $LastModifiedTime.ToUniversalTime().ToString('o')
                        }
                    
                        if ($CacheValue.PSComputerName) { $ObjectProperties['PSComputerName'] = $CacheValue.PSComputerName }
                        [PSCustomObject]$ObjectProperties
    
                    } until ($EntryPosition -eq $NumberOfEntries)
                }
    
                    else { # 64-bit
    
                    do {
                        $EntryPosition++
                        
                        $PathSize = $BinaryReader.ReadUInt16()
                        
                        # Padding
                        $null = $BinaryReader.BaseStream.Seek(6, [IO.SeekOrigin]::Current)
                        
                        $PathOffset = $BinaryReader.ReadInt64()
                        $LastModifiedTime = [DateTimeOffset]::FromFileTime($BinaryReader.ReadInt64()).DateTime
                        
                        $null = $BinaryReader.BaseStream.Seek(24, [IO.SeekOrigin]::Current)
                        
                        $Position = $BinaryReader.BaseStream.Position
                        
                        $null = $BinaryReader.BaseStream.Seek($PathOffset, [IO.SeekOrigin]::Begin)
                        
                        $Path = $UnicodeEncoding.GetString($BinaryReader.ReadBytes($PathSize))
    
                        $null = $BinaryReader.BaseStream.Seek($Position, [IO.SeekOrigin]::Begin)
                        
                        $ObjectProperties = [ordered] @{
                            PSTypeName = 'CimSweep.AppCompatCacheEntry'
                            Path = $Path
                            LastModifiedTime = $LastModifiedTime.ToUniversalTime().ToString('o')
                        }
                    
                        if ($CacheValue.PSComputerName) { $ObjectProperties['PSComputerName'] = $CacheValue.PSComputerName }
                        [PSCustomObject]$ObjectProperties
    
                    } until ($EntryPosition -eq $NumberOfEntries)
                }
            }
            
            { $_ -like '6.0*' } { <# Windows Vista / Server 2008 #> }
            
            { $_ -like '5.2*' } { <# Windows XP Pro 64-bit / Server 2003 (R2) #> }
            
            { $_ -like '5.1*' } { # Windows XP 32-bit
             
                # check for magic
                if ([BitConverter]::ToString($BinaryReader.ReadBytes(4)[3..0]) -ne 'DE-AD-BE-EF') { throw 'Not Windows XP 32-bit'}
                
                $NumberOfEntries = $BinaryReader.ReadInt32() # this is always 96, even if there aren't 96 entries
    
                $null = $BinaryReader.BaseStream.Seek(400, [IO.SeekOrigin]::Begin) # skip padding
    
                do { # parse entries
                    $EntryPosition++
                    $Path = $UnicodeEncoding.GetString($BinaryReader.ReadBytes(528)).TrimEnd("`0") # 528 == MAX_PATH + 4 unicode chars
                    $LastModifiedTime = [DateTimeOffset]::FromFileTime($BinaryReader.ReadInt64()).DateTime
                    
                    if (($LastModifiedTime.Year -eq 1600) -and !$Path) { break } # empty entries == end
    
                    $null = $BinaryReader.BaseStream.Seek(16, [IO.SeekOrigin]::Current) # skip some bytes
                    
                    $ObjectProperties = [ordered] @{
                        PSTypeName = 'CimSweep.AppCompatCacheEntry'
                        Path = $Path
                        LastModifiedTime = $LastModifiedTime.ToUniversalTime().ToString('o')
                    }
                    
                    if ($CacheValue.PSComputerName) { $ObjectProperties['PSComputerName'] = $CacheValue.PSComputerName }
                    [PSCustomObject]$ObjectProperties
    
                } until ($EntryPosition -eq $NumberOfEntries)
            }
        }
        $BinaryReader.BaseStream.Dispose()
        $BinaryReader.Dispose()
    }
    
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    $key= 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache'
    $name= 'appcompatcache'
    $AppCompatCacheValue= $(get-itemproperty -path $key -Name appcompatcache).$name
        
    $app= ConvertFrom-ByteArray -CacheValue $AppCompatCacheValue -OSVersion $OS.Version -OSArchitecture $OS.OSArchitecture | where {$_.lastmodifiedtime -like "20*"} | select lastmodifiedtime,path
       
    $hostname= $env:COMPUTERNAME
    $operatingsystem= $(Get-WmiObject win32_operatingsystem).name.tostring().split('|')[0]
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    $output= @()
    $x= 1
    foreach ($a in $app){
        $results= build-class
        $relativedate= $($a.lastmodifiedtime).split('T')[0]
        $relativename= $a.path.split('\')[-1]
        $relative_event= "$relativename-$relativedate"
        $shortpath= $a.path.split('\')[0..2]-join'\'

        $results.hostname= $hostname
        $results.operatingsystem= $operatingsystem   
        $results.datecollected= $date  
        $results.CachePosition= $x
        $results.lastmodifiedtime= $a.LastModifiedTime
        $results.path= $a.path
        $results.RelativeEvent= $relative_event
        $results.relativename= $relativename
        $results.shortpath= $shortpath
        $x++

        $output+= $results | ConvertTo-Json
    }
    $output | convertfrom-json | convertto-csv -NoTypeInformation                
}

Export-ModuleMember -Function appcompatcache
            
