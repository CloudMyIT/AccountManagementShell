$EMAIL_IN_OUPUT = $true
<#############
AD VARS
-------------
This sections contains variables that contain to active directory
#############>
$AD_USER = "admin"
$AD_PASS = "P@22word"
$AD_DOMAIN = "foobar.com"
$AD_OU_ACTIVE = "OU=Accounts,OU=foobar,DC=foobar,DC=com"
$AD_OU_DISABLED = "OU=Accounts,OU=Disabled,OU=foobar,DC=foobar,DC=com"
$AD_DEFAULT_PASSWORD = "P@22word"

<#############
EMAIL VARS
-------------
This sections contains variables that contain to email or exchange
#############>
$EMAIL_ADMIN_USER = "admin"
$EMAIL_ADMIN_PASS = "P@22word"
$EMAIL_DOMAIN = "@foobar.com"
$EMAIL_EXCHANGE_SERVER = "mail.foobar.com"
$EMAIL_FROM = "AccountManagmenet$EMAIL_DOMAIN"
$EMAIL_TO = "it$EMAIL_DOMAIN"
$EMAIL_CC = "hr$EMAIL_DOMAIN"
$EMAIL_RETENTION_DB = "retention"

<#############
SYSTEM VARS
-------------
This section contains variables that contain to windows and network settings
#############>
$SYSTEM_UDRIVEROOT = "\\MASTER\USERS"
$SYSTEM_UDRIVEARCHIVE = "\\MASTER\USERS\ARCHIVE"
