function ActiveDirectoryEnumeration{
    Remove-Variable -name properties -Force -ErrorAction SilentlyContinue

    function build-properties ($accountnames){
        $props= @()
        foreach ($a in $accountnames){
            $info= get-ADUser -Identity $a -Properties * | select * | ConvertTo-Csv | convertfrom-csv
            $prop= $($info | Get-Member | where {$_.membertype -eq "NoteProperty"}).name
            $props+= $prop

            $props= $props | sort -Unique
        }           
                    
        $props+= "Groups"
        $props= $props | where {$_ -ne "RunspaceID" -and $_ -ne "ObjectGUID"}

        return $props
    }

    function build-class($properties){
        $outputclass= [pscustomobject][ordered]@{
        IP= $null
        Hostname= $($env:computername)
        DateCollected= $null
        }
       
        foreach ($p in $properties){
            if ($p){
                $outputclass | Add-Member -NotePropertyName $p -NotePropertyValue "NULL"
            }
        }
        
    return $outputclass
   } 



    #make persistent connection to DC
    #get-pssession -name dcsesh -ErrorAction SilentlyContinue | remove-pssession
    #$dcsesh= New-PSSession -name dcsesh -ComputerName $domaincontrollerip -Credential $dccreds
    #invoke-command -Session $dcsesh -ScriptBlock {import-module activedirectory}
    #Import-PSSession -Session $dcsesh -Module activedirectory -AllowClobber | out-null

        #Get all AD info
        $Everything= Get-ADUser -Filter * 

        $Accountnames=@()
        $finaloutput= @()
        
        foreach($i in $Everything){   
            $Accountnames += $i.SamAccountName  
        }   
        

        #Check to see if property list has been built out. If not, build it.
        if (!$properties){
            $properties= build-properties $accountnames
        }
           
        foreach ($i in $Accountnames){
            #pull all info
            $results= build-class $properties
            $output= get-ADUser -Identity $i -Properties * | select * | convertto-csv | convertfrom-csv        
            
            $resultspropertylist= $($results | Get-Member | where {$_.membertype -eq "Noteproperty"}).name
            $resultspropertylist= $resultspropertylist | where {$_ -ne "IP" -and $_ -ne "Hostname" -and $_ -ne "DateCollected"}

            foreach ($r in $resultspropertylist){
                if ($output.$r){
                    $results.$r = $output.$r
                }
            }

            #get groups
            $Groups= (Get-ADPrincipalGroupMembership "$i").name-join(',')
            
            #append groups to refned output
            if ($groups){
                $results.groups = $groups
            }
            
            $finaloutput+= $results | convertto-json
        }
    
        $finaloutput | ConvertFrom-Json | convertto-csv -NoTypeInformation
    }

Export-ModuleMember -Function ActiveDirectoryEnumeration

