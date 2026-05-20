function TasksScheduled{
    function build-class{
        $outputclass= [pscustomobject][ordered]@{
            IP= "null"
            Hostname= $null
	    OperatingSystem= $null
            DateCollected= $null
            Source= "TasksScheduled"
            TaskName= $null
            TaskState= $null
            TaskPath= $null
            Action= $null
            Author= $null
        }
    return $outputclass
    }  

    $output= @()

    $hostname= $env:COMPUTERNAME
    $os= Get-CimInstance -ClassName Win32_OperatingSystem   
    $operatingsystem= "$($os.caption) $($os.version)"
    $tasks = Get-ScheduledTask
    $date= (Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join "" 

    foreach ($item in $tasks){
        $results= build-class
        $task = $item.TaskName
        
        if (!$task){
            $task= "NULL"
        }

        $state = $item.State

        if (!$state){
            $state= "NULL"
        }

        $path = $item.TaskPath

        if (!$path){
            $path= "NULL"
        }

        $author = $item.Author
	    
        if (!$author){
            $author= "NULL"
        }
	    
        $actions= $item.actions.execute
        
        if ($actions.count -gt 1){
            $action_container= @()
            foreach ($i in $item.actions){
    	        $arguments= $i.arguments
	            $action= $i.execute + " $arguments"
                $action_container+= $action
           }

            $action= $action_container-join'; '
        }
        
        if (!$action){
            $action= "NULL"
        }
        
        $results.Hostname= $hostname
	$results.operatingsystem= $operatingsystem
        $results.DateCollected= $date
        $results.TaskName= $task
        $results.TaskState= $state
        $results.TaskPath= $path
        $results.Action= $action
        $results.Author= $author

        $output+= $results | ConvertTo-Json
    }
    $output | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
}

Export-ModuleMember -Function TasksScheduled
