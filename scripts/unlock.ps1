Write-Host "Unlock Account Script"
$user = getExistingUser

Write-Host "# UAS> About to Unlock $($user.SAMAccountNAME) // $($user.DisplayName)"
pause

Unlock-ADAccount $user

##############################################################################
$Subject = "[ACCOUNT UNLOCKED] $($user.displayName)"
$Body = "
Username: $($user.SAMAccountName)
Display Name: $($user.displayName)

ACCOUNT HAS BEEN UNLOCKED

===
- START FULL ACCOUNT INFO
===
$($user | Out-String)
===
- END FULL ACCOUNT INFO
===
"
if($EMAIL_IN_OUPUT){
    Write-Host "# UAS> EMAIL BODY START"
    write-host $Body
    Write-Host "# UAS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
