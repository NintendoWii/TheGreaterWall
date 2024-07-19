function DllInformation{
        function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "DllInformation"
            ProcessName= $null
            Processpath= $null
            Module= $null
            Hash= $null
            Signature= $null
        }
    return $outputclass
    } 

    $output= @()

    $hostname= $env:COMPUTERNAME 
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
    $modules= (get-process).modules.filename | sort -Unique
    $processes= get-process
    
    foreach ($m in $modules){
        $results= build-class

        $sig= $(Get-AuthenticodeSignature $m).status

        if (!$sig){
            $sig= "NULL"
        }

        $hash= $(Get-FileHash $m).hash

        if (!$hash){
            $hash= "NULL"
        }

        $procs= $processes | where {$_.modules.filename -contains $m}
            
            foreach ($p in $procs){
                $path= $p.path

                if (!$path){
                    $path= "NULL"
                }

                $name= $p.name

                if (!$name){
                    $name= "NULL"
                }

                $results.Hostname= $hostname
                $results.operatingsystem= $operatingsystem
                $results.DateCollected= $date
                $results.ProcessName= $name
                $results.Processpath= $path
                $results.Module= $m
                $results.Hash= $hash
                $results.Signature= $sig

                $output+= $results | ConvertTo-Json
            }
        }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function DllInformation
