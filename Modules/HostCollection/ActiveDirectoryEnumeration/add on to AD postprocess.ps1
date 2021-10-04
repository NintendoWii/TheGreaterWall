$sketch= @()
$allproperties= $allproperties | where {$_.name -ne "Propertyflagged"}
$allproperties= $allproperties | where {$_.name -ne "valueflagged"}
foreach ($property in $allproperties){
    $properties= $refinedoutput.$($property.name)
    $properties= $properties | where {$_ -ne 'NULL'}
    $table= @()
    $table+= "value,low,high"
   
    foreach ($p in $properties){
        $value= $p
        if ($value){
            $p= $p.tochararray()
            $p= $p | % {[byte]$_}
            $p= $p | sort -Descending | sort -Unique | where {$_}
            $high= $p[-1]
            $low= $p[0]
            $table+= "$value,$low,$high"
        }
    }

    $table= $table | convertfrom-csv
    $lowhits= $($table | Group-Object -Property low | where {$_.count -le 50}).group.value
    $highhits= $($table | Group-Object -Property high | where {$_.count -le 50}).group.value

    foreach ($h in $lowhits){
        $hit= $refinedoutput | where {$_.$($property.name) -eq $h}

        foreach ($i in $hit){
            $i.propertyflagged = "$($property.name)"
            $i.Valueflagged = "$h"
            $sketch+= $i | ConvertTo-Json
        }
    }

    foreach ($h in $highhits){
        $hit= $refinedoutput | where {$_.$($property.name) -eq $h}

        foreach ($i in $hit){
            $i.propertyflagged = "$($property.name)"
            $i.Valueflagged = "$h"
            $sketch+= $i | ConvertTo-Json
        }
    }
 }
