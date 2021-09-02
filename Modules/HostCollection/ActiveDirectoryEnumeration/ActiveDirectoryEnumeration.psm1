function ActiveDirectoryEnumeration{
    write-output "Active Directory Enumeration"
    $Everything=Get-ADUser -Filter *
    $Accountnames=@()
    
    foreach($i in $Everything){   
        $Accountnames += $i.SamAccountName  
    }

    $Output = @()
    $Output+="Name,SID,WhenCreatedDate,WhenCreatedTime,ModifiedDate,ModifiedTime,SmartCardRequired,AccountExpirationDate,AccountExpirationTime,BadLogonCount,BadPasswordTime,PasswordNeverExpires,Groups"

    foreach($i in $Accountnames){
        Remove-Variable -Name group -Force
        Remove-Variable -Name groups -Force
        $Group=(Get-ADPrincipalGroupMembership "$i").name
        
        foreach($G in $Group){
            if(!$Groups){
                $Groups="$Groups" + "$G"
            }
            else{
                $Groups="$Groups"+"-"+"$G"
            }
        }

        $info=Get-ADUser -Identity $i -Properties Modified,PasswordNeverExpires,whencreated,SmartcardLogonRequired,Name,AccountExpirationDate,BadLogonCount,badPasswordTime,SID
        $Name=(($info | Format-List Name | findstr /r [a-z0-9]).split(":")[-1]).trimstart()
        $Name='"'+$Name+'"'
    
        if(!$Name){
            $Name="NULL"
        }
    
        $SID=(($info | Format-List SID | findstr /r [a-z0-9]).split(":")[-1]).trimstart()
        
        if(!$SID){
            $SID="NULL"
        }
    
        $WhenCreated=($info | Format-List whencreated | findstr /r [a-z0-9])-replace('whencreated : ',"")
        $WhenCreated=$WhenCreated.Split(" ")
        $WhenCreatedDate=$WhenCreated[0]
        
        if(!$WhenCreatedDate){
            $WhenCreatedDate="NULL"
        }   
         
        $WhenCreatedTime=($WhenCreated)[1]+ " " +($whencreated)[2]
        
        if(!$WhenCreatedTime){
            $WhenCreatedTime="NULL"
        }
    
        $Modified=($info | Format-List Modified | findstr /r [a-z0-9])-replace('Modified : ',"")
        $Modified=$Modified.Split(" ")
        $ModifiedDate=$Modified[0]
    
        if(!$ModifiedDate){
            $ModifiedDate="NULL"
        }
    
        $ModifiedTime=($Modified)[1]+ " " +($Modified)[2]
    
        if(!$ModifiedTime){
            $ModifiedTime="NULL"
        }
    
        $SmartCardRequired=(($info | Format-List smartcardlogonrequired | findstr /r [a-z0-9]).split(":")[-1]).trimstart()
        
        if(!$SmartCardRequired){
            $SmartCardRequired="NULL"
        }
        
        $AccountExpirationDate=($info | Format-List AccountExpirationDate | findstr /r [a-z0-9])-replace('AccountExpirationDate : ',"")
        $AccountExpirationDate=$AccountExpirationDate.Split(" ")
        $AccountExpirationDate2=$AccountExpirationDate[0]
        
        if(!$AccountExpirationDate){
            $AccountExpirationDate=""
        }
        
        if(!$AccountExpirationDate2){
            $AccountExpirationDate2=""
        }
        
        $ExpirationTime=($AccountExpirationDate)[1]+ " " +($AccountExpirationDate)[2]
        
        if(!$AccountExpirationDate -and !$AccountExpirationDate2){
            $ExpirationTime="NULL"
            $AccountExpirationDate2="NULL"
        }
        
        $BadLogonCount=(($info | Format-List BadLogonCount | findstr /r [a-z0-9]).split(":")[-1]).trimstart()
        
        if(!$BadLogonCount){
            $BadLogonCount="NULL"
        }
        
        $BadPasswordTime=(($info | Format-List badPasswordTime | findstr /r [a-z0-9]).split(":")[-1]).trimstart()
        
        if(!$BadPasswordTime){
            $BadPasswordTime="NULL"
        }
        
        $PasswordNeverExpires=(($info | Format-List PasswordNeverExpires | findstr /r [a-z0-9]).split(":")[-1]).trimstart()
        
        if(!$PasswordNeverExpires){
            $PasswordNeverExpires="NULL"
        }
    
        $Output+="$Name,$SID,$WhenCreatedDate,$WhenCreatedTime,$ModifiedDate,$ModifiedTime,$SmartCardRequired,$AccountExpirationDate2,$ExpirationTime,$BadLogonCount,$BadPasswordTime,$PasswordNeverExpires,$Groups"
    }
    
    $Output | ConvertFrom-Csv
}

Export-ModuleMember -Function ActiveDirectoryEnumeration