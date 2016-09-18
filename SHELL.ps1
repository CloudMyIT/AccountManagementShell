<#############
MAIN_MENU.ps1
-------------
Main loop for account management.
-------------
CREATED BY: Will G
CREATED AT: 17SEP16
-------------
CHANGELOG
-------------
.
#############>
$dir = Split-Path $MyInvocation.MyCommand.Path
. $dir\includes\vars.ps1
. $dir\includes\functions.ps1
. $dir\includes\hashtables.ps1

Import-Module ActiveDirectory

$command = ""
while($command -ne "q" -and $command -ne "quit")
{
    Write-Host "#> What would you like to do?"
    Write-Host "   Available Commands:"
    foreach($x in $HT_COMMANDS.Keys){
        Write-Host "   $x"
    }
    $command = Read-Host "$>"
    if($command -eq "q" -or $command -eq "quit")
    {
        Write-Host "Quiting..."
        Write-Host "Good Bye"
        exit
    }
    if($HT_COMMANDS.ContainsKey($command))
    {
        Write-Host "Running Command $command"
        & $dir\$($HT_COMMANDS[$command])
    }else{
        Write-Host "Command Not Found!"
    }
}
