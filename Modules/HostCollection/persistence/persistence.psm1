Function Persistence{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
            DateCollected= $null
            Regpath= $null
            Key= $null
            Value= $null
        }
    return $outputclass
    }  

    $output= @()
    
    $HKLM_Run = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -force
    $HKLM_RunOnce = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Force
    $HKLM_Autorun = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Command Processor" -Force
    $HKLM_Shell = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\").shell
    $HKLM_RunServices = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices" -Force -ErrorAction SilentlyContinue
    $HKLM_RunServicesOnce = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServicesOnce" -Force -ErrorAction SilentlyContinue
    $HKLM_RunOnceEx = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx" -Force -ErrorAction SilentlyContinue
    $HKLM_ExplorerRun = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run" -Force -ErrorAction SilentlyContinue
    $HKLM_Tasks = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Taskcache\Tasks" -Force -ErrorAction SilentlyContinue
    $HKLM_Tree = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Taskcache\Tree" -Force -ErrorAction SilentlyContinue
    $HKLM_Notify = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\Notify" -Force -ErrorAction SilentlyContinue
    $HKLM_Userinit = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\").Userinit
    $HKLM_ShellServiceObjectDelayLoad = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ShellServiceObjectDelayLoad" -Force
    $HKLM_AppInit_DLLs = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Windows\" -Name AppInit_DLLs)
    $HKLM_BootExecute = ((Get-ItemProperty -Path "HKLM:\\SYSTEM\ControlSet001\Control\Session Manager").bootexecute)
    $HKCU_Run = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Force
    $HKCU_RunOnce = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Force -ErrorAction SilentlyContinue
    $HKCU_Autorun = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Command Processor" -Force -ErrorAction SilentlyContinue
    $HKCU_Shell= (Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\").shell
    $HKCU_RunServices = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices" -Force -ErrorAction SilentlyContinue
    $HKCU_RunServicesOnce = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServicesOnce" -Force -ErrorAction SilentlyContinue
    $HKCU_ExplorerRun = Get-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run" -Force -ErrorAction SilentlyContinue
    $Folder_Startup = Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" -Force
    
    $hostname= $env:COMPUTERNAME
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join ""

    $regkeys= @()
    $regkeys+= 'hklm_run'
    $regkeys+= 'hklm_runonce'
    $regkeys+= 'hklm_autorun'
    $regkeys+= 'hklm_shell'
    $regkeys+= 'hklm_runservices'
    $regkeys+= 'hklm_runservicesonce'
    $regkeys+= 'hklm_runonceex'
    $regkeys+= 'hklm_explorerrun'
    $regkeys+= 'hklm_tasks'
    $regkeys+= 'hklm_tree'
    $regkeys+= 'hklm_notify'
    $regkeys+= 'hklm_userinit'
    $regkeys+= 'hklm_shellserviceobjectdelayload'
    $regkeys+= 'hklm_appinit_Dlls'
    $regkeys+= 'hklm_bootexecute'
    $regkeys+= 'hkcu_run'
    $regkeys+= 'hkcu_runonce'
    $regkeys+= 'hkcu_autorun'
    $regkeys+= 'hkcu_shell'
    $regkeys+= 'hkcu_runservices'
    $regkeys+= 'hkcu_runservicesonce'
    $regkeys+= 'hkcu_explorerrun'
    $regkeys+= 'folder_startup'

    foreach ($key in $regkeys){
        $results= build-class

        if ($key -eq "Folder_startup"){
            foreach ($i in $Folder_Startup){
                $val= $i.fullname
                $results.Hostname= $hostname
                $results.DateCollected= $date
                $results.Regpath= "FileSystem"
                $results.Key= "FileSysytem"
                $results.Value= $val
            }
            $output+= $results | ConvertTo-Json
        }

        if ($key -ne "Folder_startup"){
            $content= get-variable -name $key
            $path= $content.value.pspath
            $name= $content.value.pschildname
            $values= $content.Value.Property
    
            foreach ($v in $values){
                $v= $(Get-ItemProperty -path $path -name $v | out-string -Stream)
                $v= $v | where {$_ -like "*:*"}
                $v= $v[0]
                $v= $v-replace(': ','^')
                $v= $v.split('^')[-1]
    
                $value= $v
                $regpath= $path.tostring().split('::')[-1]
                $results.Hostname= $hostname
                $results.DateCollected= $date
                $results.Regpath= $regpath
                $results.Key= $name
                $results.Value= $value

                $output+= $results | ConvertTo-Json

            }
        }
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}
    
Export-ModuleMember -Function Persistence
