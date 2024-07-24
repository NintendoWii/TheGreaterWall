function NetworkInterfaces{

    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            OperatingSystem= $null
            DateCollected= $null
            InterfaceName= $null
            MacAddress= $null
            InterfaceAlias= $null
            DeviceID= $null
            DriverVersion= $null
            MTU= $null
            DriverFullName= $null
            DriverShortName= $null
            DriverProvider= $null
            Promiscuous= $null
            EnabledDeault= $null
            EnabledState= $null
            Status= $null
            InterfaceMTU= $null
            InterfaceDriver= $null
        }
        return $outputclass
    } 

    ####Functions end###
    #get current date
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    #Retrieve hostname, OS and domain role
    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($osversion)"

    #Get information for each network adapter
    $networkAdapters= Get-NetAdapter
    $output= @()

    foreach ($adapter in $networkAdapters){
        $interfaceName = $adapter.Name
        $macAddress = $adapter.MacAddress
        $interfaceAlias = $adapter.InterfaceAlias
        $deviceid = $adapter.DeviceID
        $driverversion = $adapter.DriverVersion
        $mtu = $adapter.MtuSize
        $driverfullname = $adapter.DriverName
        $drivershortname = $driverfullname.split('\')[-1]
        $driverprovider = $adapter.DriverProvider
        $interfaceDriver= "Interface-" + "$interfaceAlias" + '|' + "Driver-" + "$driverprovider" + " $drivershortname" + " $driverversion"
        $enableddeault = "Interface-" + "$interfaceAlias" + '|' + "EnabledDefault-" + "$($adapter.EnabledDefault)"
        $enabledstate = "Interface-" + "$interfaceAlias" + '|' + "EnabledState-" + "$($adapter.EnabledState)"
        $status = "Interface-" + "$interfaceAlias" + '|' + "Status-" + "$($adapter.status)"
        $interfaceMTU = "Interface-" + "$interfaceAlias" + '|' + "MTU-" + "$($adapter.MtuSize)"
        $promiscuous = "Interface-" + "$interfaceAlias" + '|' + "Promiscuous-" + "$($adapter.PromiscuousMode)"

        # Retrieve IP address information for the current adapter
        $ipv4= (Get-NetIPAddress | where {$_.InterfaceAlias -eq $interfaceAlias} | where {$_.AddressFamily -eq "IPv4"}).IPAddress
        $ipv6= (Get-NetIPAddress | where {$_.InterfaceAlias -eq $interfaceAlias} | where {$_.AddressFamily -eq "IPv6"}).IPAddress

        if (!$ipv4){
            $ipv4= 'Null'
        }

        if (!$ipv6){
            $ipv6= 'Null'
        }        

        <#Sometimes when a change occurs, there can be 2 values for a single property. If that's the case only keep the 'new' value
        This will loop through each variable and if there are 2 things, it'll only keep the important value.
        #>

        $props=@('interfaceName','macAddress','interfaceAlias','deviceid','driverversion','mtu','driverfullname','drivershortname','driverprovider','promiscuous','enableddeault','enabledstate','status','interfaceMTU','interfacedriver')
        foreach ($p in $props){
            $var= $(Get-Variable -name $p).Value
            if ($var.count -gt 1){
                $var= $var[-1]
                Set-Variable -name $p -Value $var -Force -ErrorAction SilentlyContinue
            }
        }

        #Append to output
        $results= build-class
        $results.Hostname = $hostname
        $results.operatingsystem = $operatingsystem
        $results.datecollected = $date
        $results.interfaceName = $interfaceName
        $results.macAddress = $macAddress
        $results.interfaceAlias = $interfaceAlias
        $results.deviceid = $deviceid
        $results.driverversion = $driverversion
        $results.mtu = $mtu
        $results.driverfullname = $driverfullname
        $results.drivershortname = $drivershortname
        $results.driverprovider = $driverprovider
        $results.promiscuous = $promiscuous
        $results.enableddeault = $enableddeault
        $results.enabledstate = $enabledstate
        $results.status = $status
        $results.interfaceMTU = $interfaceMTU
        $results.interfacedriver = $interfacedriver

        $output+= $results | convertto-json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function NetworkInterfaces
