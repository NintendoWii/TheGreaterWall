function ActiveDirectoryEnumeration{
    Remove-Variable -name properties -Force -ErrorAction SilentlyContinue
    function build-properties($sampleaccount){
        $props= @()
        $sampleaccount= $sampleaccount | out-string -Stream
        
        foreach ($s in $sampleaccount){
            $prop= $s.split(':')[0]
           $prop= $prop.trimstart().trimend()
           
            if ($prop){
                $props+= $prop
            }
        }
        $props+= "Groups"
        $props= $props | where {$_ -ne "RunspaceID" -and $_ -ne "ObjectGUID"}

        return $props
    }

    function build-class($properties){
        $outputclass= [pscustomobject][ordered]@{
        IP= $null
        Hostname= $null
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

        $accountnames= $Accountnames[50..55]

        #Check to see if property list has been built out. If not, build it.
        $x= 0
        while (!$properties){
            $sampleaccount= $accountnames[$x]
            $sampleaccount= Get-ADUser -Identity $sampleaccount -Properties *
            $properties= build-properties $sampleaccount
            $x++
        }
           
        foreach ($i in $Accountnames){
            #pull all info
            $results= build-class $properties
            $info= get-ADUser -Identity $i -Properties *
            
            #clean up output
            $output= @()
            $output+= "Property:Value"
            $info= $info | out-string -stream
            $output+= $info
            $output= $output | convertfrom-csv -Delimiter ":"
            
            foreach ($o in $output){
                $cleanproperty= $o.property
                $cleanproperty= $cleanproperty.tostring().trimend()
                $cleanvalue= $o.value
                
                if ($cleanvalue){
                    $cleanvalue= $cleanvalue.tostring().trimend()
                    $cleanvalue= $cleanvalue-replace('{','<')
                    $cleanvalue= $cleanvalue-replace('}','>')
                }

                if (!$cleanvalue){
                    $cleanvalue= "NULL"
                }

                #append to class
                if ($cleanproperty -ne "Runspaceid" -and $cleanproperty -ne "ObjectGUID" -and $cleanvalue){
                    $results.$cleanproperty = $cleanvalue                
                }
            }
            #get groups
            $Groups= (Get-ADPrincipalGroupMembership "$i").name-join(',')

            if (!$groups){
                $groups= "NULL"
            }
            
            #append groups to refned output
            $results.groups = $groups

            $finaloutput+= $results | convertto-json
        }
    
        $finaloutput | ConvertFrom-Json | convertto-csv -NoTypeInformation
    }

Export-ModuleMember -Function ActiveDirectoryEnumeration

