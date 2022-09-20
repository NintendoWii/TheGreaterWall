function smb{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
	    OperatingSystem= $null
            DateCollected= $null
            Source= "SMB"
            SMBv1= $null
            SMBv2= $Null
        }
    return $outputclass
    }  

    $output= @()
    $results= build-class

    $hostname= $env:COMPUTERNAME
    $operatingsystem= $(Get-WmiObject win32_operatingsystem).name.tostring().split('|')[0]
    $SMBVersion1 = (Get-SmbServerConfiguration).EnableSMB1Protocol
    $SMBVersion2= (Get-SmbServerConfiguration).EnableSMB2Protocol
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
	
    $results.Hostname= $hostname
    $results.operatingsystem= $operatingsystem
    $results.DateCollected= $date
    $results.SMBv1= $SMBVersion1
    $results.SMBv2= $SMBVersion2

    $output+= $results | ConvertTo-Json
	$output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
	}

export-modulemember -function smb
