
function ProcessTree{

    $Processes= Get-WmiObject -Class Win32_Process | Select-Object Name, Processid, ParentProcessid | convertto-csv
    $processes= $Processes | where {$_ -notlike "*#TYPE Selected.System.Management*"}
    $processes
}



Export-ModuleMember -Function ProcessTree
