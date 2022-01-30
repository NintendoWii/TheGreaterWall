Function AlternateDataStreams{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Source= "AlternateDataStreams"
            Stream= $null
            ZoneIdentifier= $null            
        }
    return $outputclass
    } 

    $output= @()

    $ErrorActionPreference="silentlycontinue"
    $hostname= $env:COMPUTERNAME
    $AlternateDataStreams = (Get-Childitem -Path "C:\*" -Recurse | ForEach-Object {Get-Item $_.Fullname -stream "*" | Where-Object {$_.Stream -ne ':$Data'}}).Filename

    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""
    
    Foreach ($Streams in $AlternateDataStreams){
        $results= build-class

        $ZoneIdentifier = $(Get-Content -Path "$Streams" -Stream Zone.Identifier)-join'-'

        $results.Hostname= $hostname
        $results.DateCollected= $date
        $results.Stream= $Streams
        $results.ZoneIdentifier= $ZoneIdentifier
        $output+= $results | convertto-json
        }
    $output | ConvertFrom-Json | convertto-csv -NoTypeInformation
}

Export-ModuleMember -Function AlternateDataStreams
