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

                    #define number of useraccount as half of the total count
                    $numberofuseraccounts= $($refinedoutput.samaccountname.count)/2
                        
                    #round up if decimal
                    if ($numberofuseraccounts.ToString() | select-string "\."){
                        $numberofuseraccounts= $($numberofuseraccounts.tostring().split("\."))[0]
                        $numberofuseraccounts= [int]$numberofuseraccounts+1
                    }
                
                    $sketch= @()
                    $finalout= @()
                    #find only lone occurences
                        
                    foreach ($sortproperty in $sortproperties){                        
                        $result= $($refinedoutput | Group-Object -Property $sortproperty)
                        $result
                        echo " "
                        pause}
                        ).group | where {$_.count -le $numberofuseraccounts }.group{
                            $i= $($i | convertto-csv)-replace('"','')
                            $i= $i[-1]
                            $sketch+= "$i,$sortproperty"
                        }
                        
                        #find occurences where it shows up more than once on a single endpoint    
                        #foreach ($i in $($refinedoutput | Group-Object -Property $sortproperty | where {$($_.group.$ipproperty | sort -unique).count -le $numberofendpoints}).group){
                        #    $i= $($i | convertto-csv)-replace('"','')
                        #    $i= $i[-1]
                        #    $sketch+= "$i,$sortproperty"   
                        #}
                    }

                    $finalout+= $csvheader
                    $finalout+= $sketch | sort -Unique
                                                
                    if ($finalout.count -gt 1){     
                    $finalout > $postprocessingpath\AnalysisResults\OutlyerAnalysis\ActiveDirectoryEnumeration-Analysis.csv
                    }
                }
            }  
        }