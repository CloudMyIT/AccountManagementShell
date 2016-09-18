Write-Host "Disable Account Script"
$user = getExistingUser

Write-Host "# DAS> About to Disable $($user.SAMAccountNAME) // $($user.DisplayName)"
pause

Disable-ADAccount $user

##############################################################################
$Subject = "[ACCOUNT DISABLED] $($user.displayName)"
$Body = "
Username: $($user.SAMAccountName)
Display Name: $($user.displayName)

ACCOUNT HAS BEEN DISABLED

===
- START FULL ACCOUNT INFO
===
$($user | Out-String)
===
- END FULL ACCOUNT INFO
===
"
if($EMAIL_IN_OUPUT){
    Write-Host "# DAS> EMAIL BODY START"
    write-host $Body
    Write-Host "# DAS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
