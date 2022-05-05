function Modify-Auditpolicy($eventlog,$success,$failure){
    $eventlog= 000
    $success= 111
    $failure= 222
    $category= 333
    $subcategory= 444

    function Build-PolicyObject($eventlog){
        $auditpol_categories= $(C:\windows\system32\auditpol.exe /get /category:* | select-string -Pattern ^[A-Z])
        $auditpol_categories= $auditpol_categories[2..$($auditpol_categories.count)]
        $policy_obj=@("Eventlog,Category,Subcategory, Policy")
        
        foreach ($c in $auditpol_categories){
            $subcategories= C:\windows\system32\auditpol.exe /get /category:$c | select-string -Pattern ^" "
            foreach ($s in $subcategories){
                $s= $s.tostring()-split('  ') | % {$_.trimstart().trimend()}
                $policy_obj+= "$eventlog,$($c.tostring()),$($s[1]),$($s[$($s.count -1)])"
            }
        }
        $policy_obj
    }
    
    $original_policy= Build-PolicyObject $eventlog | convertfrom-csv | where {$_.category -eq "$category" -and $_.subcategory -eq "$subcategory"}
    
    if ($success){
        $auditpolicy_change={C:\windows\system32\auditpol.exe /set /Subcategory:$($args[0]) /success:$($args[1]) | Out-Null}     
        Invoke-Command $auditpolicy_change -ArgumentList $subcategory,$success
    }
    
    if ($failure){
        $auditpolicy_change={C:\windows\system32\auditpol.exe /set /Subcategory:$($args[0]) /failure:$($args[1]) | Out-Null}
        Invoke-Command $auditpolicy_change -ArgumentList $subcategory,$failure
    }
    
    $new_policy= Build-PolicyObject $eventlog | convertfrom-csv | where {$_.category -eq "$category" -and $_.subcategory -eq "$subcategory"}
    
    $date= "[ " + $((Get-Date -Format "dd-MMM-yyyy HH:mm").Split(":") -join "") + " ]"
    write-output "*************************************"
    write-output "$date"
    Write-Output "Action: Modified Audit Policy"
    Write-Output "Target:NULL"
    Write-Output "Original Audit Policy:"
    Write-Output "$($($original_policy | out-string).tostring())"
    Write-Output "New Audit Policy:"
    Write-Output "$($($new_policy | out-string).ToString())"
    Write-output "In order to return the Audit Policy back to it's original values, please take note:"
    Write-Output "No auditing = success disabled and failure disabled"
    Write-Output "Success = Success is enabled"
    write-output "Failure = Failure is enabled"
    Write-Output "Success and Failure = Success and Failure are enabled"
}
Export-ModuleMember -Function Modify-Auditpolicy
