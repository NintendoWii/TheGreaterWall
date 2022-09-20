Function AlternateDataStreams{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "AlternateDataStreams"
            File = "$null"
            AlternateDataStream= $null
            RelativeName= $null            
        }
    return $outputclass
    } 

    $output= @()

    $ErrorActionPreference="silentlycontinue"
    $hostname= $env:COMPUTERNAME
    $operatingsystem= $(Get-WmiObject win32_operatingsystem).name.tostring().split('|')[0]
    $AlternateDataStreams = (Get-Childitem -Path "C:\*" -Recurse | ForEach-Object {Get-Item $_.Fullname -stream "*" | Where-Object {$_.Stream -ne ':$Data'}}).Filename

    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
    Foreach ($Streams in $AlternateDataStreams){
        $results= build-class

        $ZoneIdentifier = $(Get-Content -Path "$Streams" -Stream Zone.Identifier)-join'-'
        $relativename= $Streams.split('\')[-1]

        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.File= $Streams
        $results.AlternateDataStream= $ZoneIdentifier
        $results.RelativeName= $relativename
        $output+= $results | convertto-json
        }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function AlternateDataStreams
