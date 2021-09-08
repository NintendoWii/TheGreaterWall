function ActiveDirectoryEnumeration($serverip,$creds){

    function build-class{
        $outputclass= [pscustomobject][ordered]@{
        AccountExpirationDate= $null
        accountExpires= $null
        AccountLockoutTime= $null
        AccountNotDelegated= $null
        AccountPassword= $null
        AddedProperties= $null
        AllowReversiblePasswordEncryption= $null
        AuthenticationPolicy= $null
        AuthenticationPolicySilo= $null
        AuthType= $null
        BadLogonCount= $null
        badPasswordTime= $null
        badPwdCount= $null
        CannotChangePassword= $null
        CanonicalName= $null
        Certificates= $null
        ChangePasswordAtLogon= $null
        City= $null
        CN= $null
        codePage= $null
        Company= $null
        CompoundIdentitySupported= $null
        Country= $null
        countryCode= $null
        Created= $null
        createTimeStamp= $null
        Credential= $null
        Deleted= $null
        Department= $null
        Description= $null
        DisplayName= $null
        DistinguishedName= $null
        Division= $null
        DoesNotRequirePreAuth= $null
        dSCorePropagationData= $null
        EmailAddress= $null
        EmployeeID= $null
        EmployeeNumber= $null
        Enabled= $null
        Fax= $null
        GivenName= $null
        HomeDirectory= $null
        HomedirRequired= $null
        HomeDrive= $null
        HomePage= $null
        HomePhone= $null
        Initials= $null
        Instance= $null
        instanceType= $null
        isDeleted= $null
        KerberosEncryptionType= $null
        LastBadPasswordAttempt= $null
        LastKnownParent= $null
        lastLogoff= $null
        lastLogon= $null
        LastLogonDate= $null
        LockedOut= $null
        logonCount= $null
        LogonWorkstations= $null
        Manager= $null
        MemberOf= $null
        MNSLogonAccount= $null
        MobilePhone= $null
        Modified= $null
        ModifiedProperties= $null
        modifyTimeStamp= $null
        'msDS-User-Account-Control-Computed'= $null
        Name= $null
        nTSecurityDescriptor= $null
        ObjectCategory= $null
        ObjectClass= $null
        ObjectGUID= $null
        objectSid= $null
        Office= $null
        OfficePhone= $null
        Organization= $null
        OtherAttributes= $null
        OtherName= $null
        PasswordExpired= $null
        PasswordLastSet= $null
        PasswordNeverExpires= $null
        PasswordNotRequired= $null
        Path= $null
        POBox= $null
        PostalCode= $null
        PrimaryGroup= $null
        primaryGroupID= $null
        PrincipalsAllowedToDelegateToAccount= $null
        ProfilePath= $null
        PropertyCount= $null
        PropertyNames= $null
        ProtectedFromAccidentalDeletion= $null
        pwdLastSet= $null
        RemovedProperties= $null
        SamAccountName= $null
        sAMAccountType= $null
        ScriptPath= $null
        sDRightsEffective= $null
        Server= $null
        ServicePrincipalNames= $null
        SID= $null
        SIDHistory= $null
        SmartcardLogonRequired= $null
        State= $null
        StreetAddress= $null
        Surname= $null
        Title= $null
        TrustedForDelegation= $null
        TrustedToAuthForDelegation= $null
        Type= $null
        UseDESKeyOnly= $null
        userAccountControl= $null
        userCertificate= $null
        UserPrincipalName= $null
        uSNChanged= $null
        uSNCreated= $null
        whenChanged= $null
        whenCreated= $null
        groups= $null
        }
    return $outputclass
    }

    #make persistent connection to DC
    get-pssession -name dcsesh | remove-pssession
    $dcsesh= New-PSSession -name dcsesh -ComputerName $serverip -Credential $creds
    invoke-command -Session $dcsesh -ScriptBlock {import-module activedirectory}
    Import-PSSession -Session $dcsesh -Module activedirectory -AllowClobber | out-null

        #Get all AD info
        try{
            $Everything= Get-ADUser -Filter * 
        }

        catch{
            Write-output "Authenticaiton failed."
            sleep 2
            break
        }

        Finally{
        }

        $Accountnames=@()
        $output= @()
        
        foreach($i in $Everything){   
            $Accountnames += $i.SamAccountName  
            }
    
        
        foreach ($i in $Accountnames){
            $results= build-class
            $props= $($results | gm | where {$_.membertype -eq "noteproperty"}).name | where {$_ -ne "Groups"}
            $info= Get-ADUser -Identity $i -Properties *
    
            foreach ($p in $props){
                $appendedprop= $($info | where {$_.samaccountname -eq "$i"}).$p
    
                if (!$appendedprop){
                    $appendedprop= "NULL"
                }
    
                if ($appendedprop){
                    $results.$p = $appendedprop
                }
            }
    
            $Groups= (Get-ADPrincipalGroupMembership "$i").name-join(',')
    
            if (!$groups){
                $groups= "NULL"
            }
    
            if ($groups){
                $results.groups = $groups
            }
    
            $output+= $results | ConvertTo-Json
        }
    
        $output | convertfrom-json | convertto-csv -NoTypeInformation
    }

#Export-ModuleMember -Function ActiveDirectoryEnumeration
