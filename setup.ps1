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
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "EventLogs_Obfuscated" -Force
        new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "HostCollection_Obfuscated" -Force 
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
            }

        catch
            {
            Clear-Host
            write-output "Could not find TheGreaterWall.ps1. Searching for it..."
            $filepath= $($(get-childitem $env:userprofile -force -Recurse -ErrorAction SilentlyContinue | where {$_.name -eq "TheGreaterWall.ps1"}).fullName)[0]
            copy-item -path $filepath -destination $env:userprofile\Desktop\TheGreaterWall
            }
        
        #copy active directory bytes
        copy-item -path "$currentlocation\source\Active_Directory_DLL_bytes.zip" -destination "$env:userprofile\Desktop\TheGreaterWall\source\Active_Directory_DLL_bytes.zip"

        #move configuration and help pages
        copy-item -path $currentlocation\modules\modules.conf -destination $env:userprofile\Desktop\TheGreaterWall
        move-item -path $env:userprofile\desktop\thegreaterwall\modules.conf -Destination $env:userprofile\desktop\thegreaterwall\modules\modules.conf

        #$helppages= $(get-childitem -force -Recurse $currentlocation | where {$_.name -eq "Module_Help_pages"})
        copy-item -Path $currentlocation\modules\Module_Help_Pages -Recurse -Destination $env:userprofile\Desktop\TheGreaterWall\modules\ -Container
        #move-item -path $env:userprofile\desktop\thegreaterwall\module_help_pages -Destination $env:userprofile\desktop\thegreaterwall\modules\module_help_pages  

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
        if (!$(test-path $env:userprofile\desktop\TheGreaterWall\modules\eventlogs_obfuscated)){
            new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "EventLogs_Obfuscated" -Force
        }

        if (!$(test-path $env:userprofile\desktop\TheGreaterWall\modules\hostcollection_obfuscated)){
            new-item -ItemType Directory -Path "$env:userprofile\desktop\TheGreaterWall\modules" -name "hostcollection_Obfuscated" -Force
        }

        $eventlogscripts= $modules | where {$_.name -like "*log*" -and $_.name -notlike "*_GH*"}
        $obfuscatedeventlogs= $modules | where {$_.name -like "*log*" -and $_.name -like "*_GH*"}
        $hostScripts= $modules | where {$_.name -notlike "*log*" -and $_.name -notlike "*_GH*"}
        $obfuscatedhostcollection= $modules | where {$_.name -notlike "*log*" -and $_.name -like "*_GH*"}

        foreach ($e in $eventlogscripts)
            {
            move-item $e $env:userprofile\Desktop\TheGreaterWall\modules\eventlogs
            }
       
        foreach ($h in $hostScripts)
            {

            move-item $h $env:userprofile\Desktop\TheGreaterWall\modules\hostcollection
            }

        foreach ($e in $obfuscatedeventlogs)
            {
            move-item $e $env:userprofile\Desktop\TheGreaterWall\modules\eventlogs_obfuscated
            }
       
        foreach ($h in $obfuscatedhostcollection)
            {
            move-item $h $env:userprofile\Desktop\TheGreaterWall\modules\hostcollection_obfuscated
            }       
       
        #base64 Decode all the Modules
        
        #check to see which modules have or dont have obfuscation
        $modules= Get-ChildItem -Recurse $env:userprofile\desktop\thegreaterwall\modules | where {$_.name -like "*psm1*" -and $_.name -notlike "reformat*"}
        $decode= $($modules | where {$_.name -like "*_GH*"}).fullname

        
        $plainttext= $($modules | where {$_.name -notlike "*_GH*"}).name
        $obfuscated= $($modules | where {$_.name -like "*_GH*"}).name | % {$_-replace("_obfuscated_GH","")}
        $noobfuscation= $(Compare-Object $plainttext $obfuscated | where {$_.sideindicator -eq "<="}).inputobject
        $noplaintext= $(Compare-Object $obfuscated $plainttext | where {$_.sideindicator -eq "<="}).inputobject


        #rename the obfuscated folders
        $folders= @()
        $folders+= $(Get-ChildItem $env:userprofile\desktop\thegreaterwall\modules\eventlogs_obfuscated)
        $folders+= $(Get-ChildItem $env:userprofile\desktop\thegreaterwall\modules\hostcollection_obfuscated)

        foreach ($f in $folders){
        $oldname= $f.fullname
        $newname= $f.name-replace("_GH","")
        Rename-Item -Path $oldname -NewName $newname
        }

        #rename the obfuscated files and decode them
        $files=@()
        $files+= $(Get-ChildItem -Recurse $env:userprofile\desktop\thegreaterwall\modules\eventlogs_obfuscated | where {$_.name -like "*_GH*"})
        $files+= $(Get-ChildItem -Recurse $env:userprofile\desktop\thegreaterwall\modules\HostCollection_obfuscated | where {$_.name -like "*_GH*"})

        clear-host
        Write-host "Decoding all of the encoded modules. Please be patient."

        foreach ($f in $files){
            $oldname= $f.fullname
            $newname= $f.name-replace("_GH","")

            $array= get-content $oldname
            $output= @()
            $final= ""
           
            foreach ($a in $array){
                $output+= [char][byte]$a
            }
        
            $x= 0
            while ($x -le $output.count){
                $final= $final + $output[$x]
                $x++
            }

            $final= $final.split('~') 
            $final >$oldname
            Rename-Item -Path $oldname -NewName $newname
        }

        set-location $env:userprofile\desktop\thegreaterwall
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
