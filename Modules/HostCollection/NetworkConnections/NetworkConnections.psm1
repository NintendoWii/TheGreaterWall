function NetworkConnections{
$connections= Get-NetTCPConnection | select localaddress,localport,remoteaddress,remoteport,state,owningprocess | convertto-csv
$connections= $connections | where {$_ -notlike "*#TYPE Selected.Microsoft.Management*"}
$Connections
}

Export-ModuleMember -Function NetworkConnections
