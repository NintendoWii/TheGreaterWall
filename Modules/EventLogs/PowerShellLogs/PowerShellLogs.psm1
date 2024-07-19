function PowershellLogs{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            Source= "PowerShellLogs"
            ID= "4104"
            RecordID= $null
            ProcessID= $null
            UserSID= $null
            TimeCreated= $null
            MessageHash= $null
            Scriptblockid= $null
        }
    return $outputclass
    }  

    $output= @()

    $PowershellLogs= $(Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" | where {$_.id -eq 4104})

    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"
    $datecollected= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    $x= 0
    foreach ($i in $powershellLogs){
        $results= build-class
        $recordid= $i.RecordId
        $message= $i.message | Convertfrom-csv | ConvertTo-Csv
        $message= $message | select-string -NotMatch -pattern "^.path:"
        $scriptblockid= $($message | select-string -pattern "^.ScriptBlock ID:").tostring()
        $scriptblockid= $scriptblockid.TrimStart('"').trimend('"')
        $message= $message | select-string -NotMatch -pattern "^.ScriptBlock ID:"
        $message= $message | select-string -NotMatch -pattern "text \([0-9] of [0-9]\)"
        $message= $message | select-string -NotMatch "#TYPE System.Management.Automation.PSCustomObject"
        $message= $message | % {$_.tostring().TrimStart().trimend()}

        #cant do this in constrained language mode
        #$message= Get-FileHash -InputStream ([System.IO.MemoryStream]::New([System.Text.Encoding]::ASCII.GetBytes($message)))
        #$message= $message.hash 
               
        #calulate message hash to accomplish the hashing concept in constrained language mode
        $verbosemessage= $message
        $message= $message.tochararray() | % {[byte]$_}
        $messagehash= $($message | Measure-Object -sum).sum

        $processid= $i.processid.tostring()
        $user= $i.userid.tostring()
        $timecreated= $i.timecreated.tostring()
        
        $results.Hostname= $hostname
        $results.operatingsystem= $operatingsystem
        $results.DateCollected= $datecollected
        $results.id= "4104"
        $results.RecordID= $recordid
        $results.ProcessID= $processid
        $results.UserSID= $user
        $results.TimeCreated= $timecreated
        $results.MessageHash= $messagehash
        $results.Scriptblockid= $scriptblockid

        $output+= $results | ConvertTo-Json

        #output whole messaage and record id to STD out
        write-output "TGWIndex= $x"
        write-output "Recordid= $recordid"
        Write-Output "messagehash= $messagehash"
        Write-output "ScriptblockID= $scriptblockid"
        Write-Output $verbosemessage
        $x++
    }
    write-output "*****START CSV******"
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
    write-output "*****END CSV******"
}

Export-ModuleMember -Function PowershellLogs
