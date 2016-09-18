Write-Host "Account Creation Script"
$CONTINUE = $false

<#
Name Information
#>
Write-Host "# ACS> First Name?"
$nameFirst = Read-Host "$ ACS>"
Write-Host "# ACS> Last Name?"
$nameLast = Read-Host "$ ACS>"
$samName = getNewSAMName $nameFirst $nameLast
Write-Host "# ACS> Depatment?"
Write-Host "       Available Departments:"
foreach($x in $HT_MASTER.Keys)
{
    if($x -notlike "STATIC_POSITIONS")
    {
        Write-Host "       $x"
    }
}
while($CONTINUE -ne $true)
{
    $department = Read-Host "$ ACS>"
    if($HT_MASTER.ContainsKey($department) -eq $true -and $department -notlike "STATIC_POSITIONS")
    {
        $CONTINUE = $true
    }else{
        Write-Host "# ACS> INVALID DEPARTMENT"
    }
}
$CONTINUE = $false

Write-Host "# ACS> Position?"
Write-Host "       Available Positions:"
foreach($x in $HT_MASTER[$department]["POSITIONS"].Keys)
{
    Write-Host "       $x"
}
while($CONTINUE -ne $true)
{
    $position = Read-Host "$ ACS>"
    if($HT_MASTER[$department]["POSITIONS"].ContainsKey($position) -eq $true)
    {
        $CONTINUE = $true
    }else{
        Write-Host "# ACS> INVALID POSITION"
    }
}
$CONTINUE = $false

Write-Host "# ACS> Location?"
Write-Host "       Available Locations:"
foreach($x in $HT_LOCATIONS.Keys)
{
    Write-Host "       $x"
}
while($CONTINUE -ne $true)
{
    $location = Read-Host "$ ACS>"
    if($HT_LOCATIONS.ContainsKey($location) -eq $true)
    {
        $CONTINUE = $true
    }else{
        Write-Host "# ACS> INVALID LOCATION"
    }
}
$CONTINUE = $false

if($HT_MASTER[$department]["EXT"] -eq "LOCATION" -and $HT_DEFAULT_EXT["LOCATION"].ContainsKey($location))
{
    $defaultEXT = $HT_DEFAULT_EXT["LOCATION"][$location]
}elseif($HT_MASTER[$department]["EXT"] -eq "POSITION" -and $HT_DEFAULT_EXT["POSITION"].ContainsKey($position)){
    $defaultEXT = $HT_DEFAULT_EXT["POSITION"][$position]
}else{
    $defaultEXT = "0000"
}

Write-Host "# ACS> Telephone Extension?"
Write-Host "       <DEFAULT: $defaultEXT>"
$extension = Read-Host "$ ACS>"
if($extension -eq $null -or $extension -eq "")
{
    $extension = $defaultEXT
}

Write-Host "# ACS> Mailbox Database?"
Write-Host "       <DEFAULT: none>"
foreach($x in $HT_MX_DATABASE.Keys)
{
    Write-Host "       $x"
    Write-Host "            $($HT_MX_DATABASE[$x])"
}
while($CONTINUE -eq $false)
{
    $mailboxdb = Read-Host "$ ACS>"
    if($HT_MX_DATABASE.ContainsKey($mailboxdb))
    {
        $CONTINUE = $true
    }elseif($mailboxdb -eq $null -or $mailboxdb -eq ""){
        $mailboxdb = "none"
        $CONTINUE = $true
    }else{
        Write-Host "# ACS> INVALID MAILBOX DATABASE"
    }
}


$OU = "$($HT_MASTER[$department]["POSITIONS"][$position]["OU"])$($HT_MASTER[$department]["OU"])$AD_OU_ACTIVE"
<#
WARNING
#>
write-host "# ACS> PLEASE REVIEW CLOSE SCRIPT TO CANCEL"
write-host ""
Write-Host "First Name: $nameFirst"
Write-Host "Last Name: $nameLast"
Write-Host "Display Name: $nameFirst $nameLast"
Write-Host "Username: $samName"
Write-Host "Extension: $extension"
Write-Host "Email Address: $samName$EMAIL_DOMAIN"
Write-Host "Department: $department"
Write-Host "Position $position"
Write-Host "U Drive Location: $SYSTEM_UDRIVEROOT\$samName"
Write-Host "OU: $OU"
Write-Host ""
pause

$NewUser = New-ADUser `
	-GivenName $nameFirst `
	-Surname $nameLast `
	-DisplayName "$nameFirst $nameLast" `
	-SamAccountName $samName `
	-Name $samName `
	-HomeDirectory "$SYSTEM_UDRIVEROOT\$samName" `
	-ProfilePath "$SYSTEM_UDRIVEROOT\$samName\_sys\$SAMName.pds" `
	-HomeDrive "U:" `
    -OfficePhone $extension `
    -Department $department `
    -Title $position `
    -City $location `
	-Path $OU `
	-UserPrincipalName "$samName@$AD_DOMAIN" `
	-EmailAddress "$samName$EMAIL_DOMAIN" `
	-AccountPassword (convertto-securestring "P@22word" -asplaintext -force) `
	-CannotChangePassword $false `
	-ChangePasswordAtLogon $true `
	-Enabled $true `
	-PassThru `
	-PasswordNeverExpires $false `
	-PasswordNotRequired $false `
	-SmartcardLogonRequired $false `
	-TrustedForDelegation $false `
	-Type "User"
    #-AllowReversiblePasswordEncryption $false `
	#-OtherName $OtherName `







New-Item -ItemType Directory -Force -Path "$SYSTEM_UDRIVEROOT\$samName"
#Define FileSystemAccessRights:identifies what type of access we are defining, whether it is Full Access, Read, Write, Modify 
$FileSystemAccessRights = [System.Security.AccessControl.FileSystemRights]"FullControl" 
#define InheritanceFlags:defines how the security propagates to child objects by default 
#Very important - so that users have ability to create or delete files or folders in their folders 
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit" 
#Define PropagationFlags: specifies which access rights are inherited from the parent folder (users folder). 
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None 
#Define AccessControlType:defines if the rule created below will be an 'allow' or 'Deny' rule 
$AccessControl =[System.Security.AccessControl.AccessControlType]::Allow  
#define a new access rule to apply to users folfers 
$NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("$AD_DOMAIN\$samName", $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)  
#Get the current ACL for the folder
$currentACL = Get-ACL -path "$SYSTEM_UDRIVEROOT\$samName" 
#Add this access rule to the ACL 
$currentACL.SetAccessRule($NewAccessrule) 
#Write the changes to the user folder 
Set-ACL -path "$SYSTEM_UDRIVEROOT\$samName" -AclObject $currentACL
#DOMAIN ADMINS
$NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("$AD_DOMAIN\Domain Admins", $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)  
#Get the current ACL for the folder
$currentACL = Get-ACL -path "$SYSTEM_UDRIVEROOT\$samName" 
#Add this access rule to the ACL 
$currentACL.SetAccessRule($NewAccessrule) 
#Write the changes to the user folder 
Set-ACL -path "$SYSTEM_UDRIVEROOT\$samName" -AclObject $currentACL





if($mailboxdb -ne "none")
{
    $CREDS=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $EMAIL_ADMIN_USER, (convertto-securestring $EMAIL_ADMIN_PASS -asplaintext -force)
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$EMAIL_EXCHANGE_SERVER/PowerShell/ -Authentication Kerberos -Credential $UserCredential
    Import-PSSession $Session
    Enable-Mailbox -Identity "$AD_DOMAIN\$samName" -Database $mailboxdb
    Remove-PSSession $Session
}





foreach($deptGroup in $HT_MASTER[$department]["GROUPS"])
{
    try{
        Add-ADGroupMember $deptGroup $NewUser
    }catch{
        Write-Host "# ACS> ERROR ADDING $deptGroup"
    }
}
foreach($posGroup in $HT_MASTER[$department]["POSITIONS"][$position]["GROUPS"])
{
    try{
        Add-ADGroupMember $posGroup $NewUser
    }catch{
        Write-Host "# ACS> ERROR ADDING $postGroup"
    }
}


##############################################################################
$Subject = "[ACCOUNT CREATED] $nameFirst $nameLast $samName"
$Body = "
First Name: $nameFirst
Last Name: $nameLast
Display Name: $nameFirst $nameLast
Username: $samName
Extension: $extension
Email Address: $samName$EMAIL_DOMAIN
Department: $department
Position $position
U Drive Location: $SYSTEM_UDRIVEROOT\$samName
-------------
GROUPS
-------------
"
foreach($deptGroup in $HT_MASTER[$department]["GROUPS"])
{
    $Body = "$Body $deptGroup
"
}
foreach($posGroup in $HT_MASTER[$department]["POSITIONS"][$position]["GROUPS"])
{
    $Body = "$Body $posGroup
"
}
$Body = "$Body
===
- START FULL ACCOUNT INFO
===
$($user | Out-String)
===
- END FULL ACCOUNT INFO
===
"
if($EMAIL_IN_OUPUT){
    Write-Host "# ACS> EMAIL BODY START"
    write-host $Body
    Write-Host "# ACS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
