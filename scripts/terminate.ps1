Write-Host "Terminate Account Script"
$user = getExistingUser

Write-Host "# TAS> About to Terminate $($user.SAMAccountNAME) // $($user.DisplayName)"
pause

Disable-ADAccount $user

$GROUPS_REMOVED = @()
foreach($grp in $user.memberof)
{
    $GROUPS_REMOVED = $GROUPS_REMOVED + @($grp)
    Remove-ADGroupMember -identity $grp -member $user -confirm:$false
}

Move-ADObject -Identity $user -TargetPath $AD_OU_DISABLED

$CREDS=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $EMAIL_ADMIN_USER, (convertto-securestring $EMAIL_ADMIN_PASS -asplaintext -force)
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$EMAIL_EXCHANGE_SERVER/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session
Get-MoveRequest -MoveStatus Completed | Remove-MoveRequest
New-MoveRequest -Identity "$AD_DOMAIN\$samName" -TargetDatabase $EMAIL_RETENTION_DB
Remove-PSSession $Session

##############################################################################
$Subject = "[ACCOUNT TERMINATED] $($user.displayName)"
$Body = "
Username: $($user.SAMAccountName)
Display Name: $($user.displayName)

ACCOUNT HAS BEEN TERMINATED
MAILBOX HAS BEEN MOVED TO RETENTION DATABASE

-------------
GROUPS REMOVED
-------------
"
foreach($grp in $GROUPS_REMOVED)
{
    $Body = "$Body $grp
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
    Write-Host "# TAS> EMAIL BODY START"
    write-host $Body
    Write-Host "# TAS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
