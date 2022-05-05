function setup-framework
        {
        $ErrorActionPreference= "SilentlyContinue"
        #Make folders
        new-item -ItemType Directory -Path $env:userprofile\desktop -name "TheGreaterWall" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall" -name "Source" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall" -name "Modules" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "HostCollection" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "EventLogs" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall" -name "Results" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall" -name "TgwLogs" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\TgwLogs" -name "PowerShell_Master_Reference" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "Module_Help_Pages" -Force 
	  new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "Framework_Dependency_Modules" -Force 
        #new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\source" -name "Baselineresults" -Force
        #new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\source\Baselineresults" -name "Server-2019" -Force  
        #new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\source\Baselineresults" -name "Server-1809" -Force  
        #new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\source\Baselineresults" -name "Windows-1809" -Force   
        
        #Add new folder to $psmodulepath so powershell can located them when you try to import-module
            if ($env:psmodulepath -notlike "*$env:userprofile\Desktop\TheGreaterWall\modules*")
                {
                $env:PSModulePath= $env:PSModulePath + ";$env:userprofile\Desktop\TheGreaterWall\modules"
                }
        
        #find current location and prepare to move files
        try
            {
        $currentlocation= $(get-location).Path.tostring()
            }

        catch
            {
        $currentlocation= $(get-location).Path | findstr /r [a-z0-9]
            }

        #move the framework to a useable location
        try
            {
            copy-item -path "$currentlocation/source/TheGreaterWall.ps1" -destination "$env:userprofile\Desktop\TheGreaterWall\source\TheGreaterWall.ps1"
            copy-item -path "$currentlocation/source/TGW_Logbeat.yml" -destination "$env:userprofile\Desktop\TheGreaterWall\source\TGW_Logbeat.yml"
            }

        catch
            {
            Clear-Host
            write-output "Could not find TheGreaterWall.ps1. Searching for it..."
            $filepath= $($(get-childitem $env:userprofile -force -Recurse -ErrorAction SilentlyContinue | where {$_.name -eq "TheGreaterWall.ps1"}).fullName)[0]
            copy-item -path $filepath -destination $env:userprofile\Desktop\TheGreaterWall
            }       

        #move configuration and help pages
        copy-item -path $currentlocation\modules\modules.conf -destination $env:userprofile\Desktop\TheGreaterWall
        move-item -path $env:userprofile\desktop\thegreaterwall\modules.conf -Destination $env:userprofile\desktop\thegreaterwall\modules\modules.conf

        copy-item -Path $currentlocation\modules\Module_Help_Pages -Recurse -Destination $env:userprofile\Desktop\TheGreaterWall\modules\ -Container  
	
	#Move Framework Dependency Modules
	copy-item -Path $currentlocation\Framework_Dependency_Modules\Modify-AuditPolicy -Recurse -Destination $env:userprofile\Desktop\TheGreaterWall\modules\Framework_Dependency_Modules -Container
	
        ####Move all modules to the new folder
        $modules= $(get-childitem -force -Recurse $currentlocation | where {$_.extension -eq ".psm1"}) | sort -Unique
        clear-host
            foreach ($m in $modules)
                {
                $name= $m.name.tostring().split('.')[0]
                    if (!$(Test-Path $env:userprofile\desktop\TheGreaterWall\modules\$name))
                        {
                        Write-output "New Module Detected. Setting Things up...($m)"
                        sleep -m 250
                        copy-item -path $m.FullName -destination $env:userprofile\Desktop\TheGreaterWall\modules
                        }
                }


        #make module folders 
        $modules= $(Get-ChildItem $env:userprofile\Desktop\TheGreaterWall\modules | where {$_.name -like "*psm1*"}).Name 
        
        foreach ($m in $modules)
	        {
            $m= $m-replace(".psm1","")
            new-item -ItemType Directory -path $env:userprofile\Desktop\TheGreaterWall\modules -name $m
            move-item "$env:userprofile\Desktop\TheGreaterWall\modules\$m.psm1" $env:userprofile\Desktop\TheGreaterWall\modules\$m
            }
        
        Set-Location $env:userprofile\desktop\thegreaterwall\modules

        $modules= Get-ChildItem $env:userprofile\Desktop\TheGreaterWall\modules | where {$_.name -notlike "eventlogs*" -and $_.name -notlike "Hostcollection*" -and $_.name -ne "Module_Help_Pages" -and $_.name -ne "modules.conf"}

        #move modules to their correct folder (HostCollection or EventLogs)

        $eventlogscripts= $modules | where {$_.name -like "*log*" -and $_.name -notlike "*_GH*"}
        $hostScripts= $modules | where {$_.name -notlike "*log*" -and $_.name -notlike "*_GH*"}

        foreach ($e in $eventlogscripts)
            {
            move-item $e $env:userprofile\Desktop\TheGreaterWall\modules\eventlogs
            }
       
        foreach ($h in $hostScripts)
            {

            move-item $h $env:userprofile\Desktop\TheGreaterWall\modules\hostcollection
            }              

        set-location $env:userprofile\desktop\thegreaterwall
	#unblock everything
        $unblockfiles= $(Get-ChildItem -Force -Recurse | where {$_.Extension -eq ".ps1" -or $_.Extension -eq ".psm1"}).fullname
        $unblockfiles | % {Unblock-File -Path $_}
        clear-host
        Write-Output "Finished setting up framework and dependecies"
	    Write-Output "To use The Greater Wall, open PowerShell ISE as Administrator and"
        write-output "Go to $env:userprofile\Desktop\TheGreaterWall\Source to access the framework"
        Write-Output " "

        pause
        clear-host
}

setup-framework
start-process powershell_ise -verb runas -ArgumentList $env:userprofile\desktop\thegreaterwall\source\thegreaterwall.ps1
