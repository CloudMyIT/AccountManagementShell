Write-Host "Modify Account Script"
$user = getExistingUser
$CONTINUE = $false

Write-Host "# MAS> Depatment?"
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
    $department = Read-Host "$ MAS>"
    if($HT_MASTER.ContainsKey($department) -eq $true -and $department -notlike "STATIC_POSITIONS")
    {
        $CONTINUE = $true
    }else{
        Write-Host "# MAS> INVALID DEPARTMENT"
    }
}
$CONTINUE = $false

Write-Host "# MAS> Position?"
Write-Host "       Available Positions:"
foreach($x in $HT_MASTER[$department]["POSITIONS"].Keys)
{
    Write-Host "       $x"
}
while($CONTINUE -ne $true)
{
    $position = Read-Host "$ MAS>"
    if($HT_MASTER[$department]["POSITIONS"].ContainsKey($position) -eq $true)
    {
        $CONTINUE = $true
    }else{
        Write-Host "# MAS> INVALID POSITION"
    }
}
$CONTINUE = $false

$GROUPS_REMOVED = @()
foreach($group in $user.MemberOf)
{
    if($HT_ALLGROUPS.Contains((Get-ADGroup $group).Name))
    {
        try{
            Remove-ADGroupMember -identity $group -member $user -confirm:$false
            $GROUPS_REMOVED = $GROUPS_REMOVED + @($deptGroup)
        } catch {
            Write-Host "# MAS> ERROR REMOVING $((Get-ADGroup $group).Name)"
        }
    }
}


$GROUPS_ADDED = @()
foreach($deptGroup in $HT_MASTER[$department]["GROUPS"])
{
    try{
        Add-ADGroupMember $deptGroup $user
        $GROUPS_ADDED = $GROUPS_ADDED + @($deptGroup)
    }catch{
        Write-Host "# MAS> ERROR ADDING GROUP $deptGroup"
    }
}
foreach($posGroup in $HT_MASTER[$department]["POSITIONS"][$position]["GROUPS"])
{
    try{
        Add-ADGroupMember $posGroup $user
        $GROUPS_ADDED = $GROUPS_ADDED + @($posGroup)
    }catch{
        Write-Host "# MAS> ERROR ADDING GROUP $posGroup"
    }
}

$OU = "$($HT_MASTER[$department]["POSITIONS"][$position]["OU"])$($HT_MASTER[$department]["OU"])$AD_OU_ACTIVE"
Move-ADObject -Identity $user -TargetPath $OU

Set-ADUser -Title $position -Department $department -City $location -Identity $user


##############################################################################
$Subject = "[PERMISSIONS REMOVED] $($user.displayName)"
$Body = "
Username: $($user.SAMAccountName)
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
-------------
GROUPS ADDED
-------------
"
foreach($grp in $GROUPS_ADDED)
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
    Write-Host "# MAS> EMAIL BODY START"
    write-host $Body
    Write-Host "# MAS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
