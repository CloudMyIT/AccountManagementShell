Write-Host "Expire Account Script"
$user = getExistingUser

Write-Host "# EXAS> When should the account expire?"
Write-Host "        MM/DD/YYY HH:MM AM/PM"
$datetime = Read-Host "$ EXAS>"

Write-Host "# EXAS> About set expiration date of $datetime for $($user.SAMAccountNAME) // $($user.DisplayName)"
pause

Set-ADAccountExpiration $user -DateTime $datetime

##############################################################################
$Subject = "[ACCOUNT EXPIRY] $($user.displayName) - $datetime"
$Body = "
Username: $($user.SAMAccountName)
Display Name: $($user.displayName)

ACCOUNT WILL EXPIRE AT $datetime

===
- START FULL ACCOUNT INFO
===
$($user | Out-String)
===
- END FULL ACCOUNT INFO
===
"
if($EMAIL_IN_OUPUT){
    Write-Host "# EXAS> EMAIL BODY START"
    write-host $Body
    Write-Host "# EXAS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
