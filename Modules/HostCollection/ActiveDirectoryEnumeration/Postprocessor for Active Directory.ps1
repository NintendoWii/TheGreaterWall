        Function identify-ActiveDirectoryOutlyers{
            $start= get-date
            #new-item -ItemType Directory -Path $postprocessingpath\AnalysisResults -name OutlyerAnalysis -ErrorAction SilentlyContinue | out-null
            remove-variable -Name refinedoutput -Force -ErrorAction SilentlyContinue
            remove-variable -name output -Force -ErrorAction SilentlyContinue
        
            if (!$moduleconfiguration){
                $moduleconfiguration= Get-Content $env:USERPROFILE\Desktop\TheGreaterWall\Modules\Modules.conf | Convertfrom-csv -Delimiter :
                New-Variable -name obj -Value $($moduleconfiguration) -Force -ErrorAction SilentlyContinue
            }
            
            if ($moduleconfiguration){
                #parse File for selected data
                $settings= $obj | where {$_.p1 -eq "ActiveDirectoryEnumeration"}
                $sortproperties= $($settings | where {$_.p2 -eq "Pivot"}).p3                

                #get contents of file
                $path= "$postprocessingpath\RawData\all_activedirectoryEnumeration.csv"
                $output= get-content $path -ErrorAction SilentlyContinue
                                

                if (!$output){
                    Write-Host "[Warning] no Active Directory file" -ForegroundColor Red
                }
                
                if ($output){
                    $refinedoutput= $output | ConvertFrom-Csv
                    $refinedoutput | Add-Member -NotePropertyName Propertyflagged -NotePropertyValue "NULL"
                    $accounts= $refinedoutput.samaccountname

                    #define number of useraccounts as half of the total count
                    $numberofuseraccounts= $($refinedoutput.samaccountname.count)/2
                        
                    #round up if decimal
                    if ($numberofuseraccounts.ToString() | select-string "\."){
                        $numberofuseraccounts= $($numberofuseraccounts.tostring().split("\."))[0]
                        $numberofuseraccounts= [int]$numberofuseraccounts+1
                    }
                                    
                    $finalout= @()
                    #find only lone occurences of true/false values
                        
                    foreach ($sortproperty in $sortproperties){    
                        $sketch= @()                
                        $result= $refinedoutput | Group-Object -Property $sortproperty                        
                        $result= $result | where {$_.count -le $numberofuseraccounts}
                        $propertyflagged= $sortproperty
                        
                        foreach ($i in $result.group){
                            $i.Propertyflagged = $propertyflagged
                            $i= $i | ConvertTo-Json
                            $sketch+= $i
                        }                    
                        
                        $finalout+= $sketch
                    }                        
                    
                    #grab all properties
                    $allproperties= $($refinedoutput[0] | get-member | where {$_.membertype -eq "noteproperty"})

                    #find occurences where the majority of the values are "NULL", but some aren't and vice versa
                    $nullproperties= $($allproperties | where {$_.definition -like "*=NULL"}).name | sort -unique
                    $sketch= @()

                    foreach ($nullproperty in $nullproperties){    
                        $sketch= @()                
                        $result= $refinedoutput | Group-Object -Property $nullproperty

                        if ($($result | where {$_.name -eq "Null"}).count -ge $numberofuseraccounts){                   
                            $result= $result | where {$_.count -le $numberofuseraccounts}
                            $propertyflagged= "$nullproperty is not Null"
                        }

                        if ($($result | where {$_.name -eq "Null"}).count -le $numberofuseraccounts){                   
                            $result= $result | where {$_.name -eq "Null"}
                            $propertyflagged= "$nullproperty is NULL"
                        }
                        
                        if ($result){
                            foreach ($i in $result.group){
                                $i.Propertyflagged = $propertyflagged
                                $i= $i | ConvertTo-Json
                                $sketch+= $i
                            }                    
                                    
                            $finalout+= $sketch
                        }  
                    }
                
                    #look for abnormally long values
                    $sketch= @()
                    $propertytable= @()
                    $propertytable+= "property,value,Length"
                    $allprops= $allproperties.name

                    foreach ($r in $refinedoutput){
                        
                        foreach ($a in $allprops){
                            $value= $r.$a.tostring()
                            $propertytable+= "$a,$value,$($value.length)"
                        }
                    }

                    $propertytable= $propertytable | convertfrom-csv
                    
                    foreach ($a in $allproperties){
                        $props= $($propertytable | where {$_.property -eq "$($a.name)"} | Group-Object -Property length)
                        
                        #Get the most common property length and find occurences where theres properties 10 chars larger 
                        if ($props.name.count -ge 2){
                            [int]$commonprop= $($props | sort -Descending -Property count)[0].name
                            $prop= @()

                            foreach ($p in $props){
                                $p
                                if ([int]$p.name -ge $($commonprop + 10)){
                                    $prop+= $p
                                }
                            }
                        }}

                        foreach ($p in $prop){
                            $p= $($propertytable | where {$_.length -eq "$($p.name)" -and $_.property -eq "$($a.name)"}).value | sort -Unique
                            $propertyflagged= "$($a.name)-Length"
                            
                            foreach ($subproperty in $p.group){
                                $subproperty= $subproperty.value                                    
                                $hit= $($refinedoutput | where {$_.$($a.name) -eq "$subproperty"})
                                
                                foreach ($h in $hit){
                                   $h.propertyflagged = $propertyflagged
                                   $h= $h | ConvertTo-Json
                                   $sketch+= $h
                                }
                            }
                        }
                    }
                }
                                                
                    if ($finalout.count -gt 1){     
                    new-item -ItemType Directory -name OutlyerAnalysis -Path $postprocessingpath\AnalysisResults -ErrorAction SilentlyContinue
                    $finalout= $finalout | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation
                    $finalout > $postprocessingpath\AnalysisResults\OutlyerAnalysis\ActiveDirectoryEnumeration-Analysis.csv
                    }
                }
            }  
        }