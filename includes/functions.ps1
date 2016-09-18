function getExistingUser
{
    $FOUNDUSER = $false
    while($FOUNDUSER -eq $false)
    {
        Write-Host "Enter the Users Login or Email Address"
        $username = Read-Host "$>"
        $user = Get-ADUser -Properties * -Filter "mail -like '$username$EMAIL_DOMAIN' -or SAMAccountName -eq '$username'"
        if($user -ne $null)
        {
            $FOUNDUSER = $true
        }else{
            Write-Host "Account Not Found"
        }
    }
    return $user
}

function checkSAMNameExists([string] $SAMName)
{
    try{
        $user = Get-ADUser $SAMName
        return $true
    } catch {
        return $false
    }
}

function getNewSAMName([string] $first, [string] $last, [int] $x = 1, [int] $padding = 1)
{
    try{
        $SAMName = ("$($first.Substring(0,$x))$last").toLower()
        if(checkSAMNameExists $SAMName){
            getNewSAMNAme $first $last $($x+1)
        }else{
            return $SAMName
        }
    } catch {
        $SAMName = ("$first$last$padding").toLower()
        if(checkSAMNameExists $SAMName){
            getNewSAMNAme $first $last $x $($padding+1)
        }else{
            return $SAMName
        }
    }
        
}
