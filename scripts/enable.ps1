Write-Host "Enable Account Script"
$user = getExistingUser

Write-Host "# EAS> About to Disable $($user.SAMAccountNAME) // $($user.DisplayName)"
pause

Enable-ADAccount $user

##############################################################################
$Subject = "[ACCOUNT ENABLED] $($user.displayName)"
$Body = "
Username: $($user.SAMAccountName)
Display Name: $($user.displayName)

ACCOUNT HAS BEEN ENABLED

===
- START FULL ACCOUNT INFO
===
$($user | Out-String)
===
- END FULL ACCOUNT INFO
===
"
if($EMAIL_IN_OUPUT){
    Write-Host "# EAS> EMAIL BODY START"
    write-host $Body
    Write-Host "# EAS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
