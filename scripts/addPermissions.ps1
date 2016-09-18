Write-Host "Add Permissions Script"
$user = getExistingUser
$GROUPS_ADDED = @()

$choice = ""
while($choice -ne "quit" -and $choice -ne "q")
{
    Write-Host "# APS> Department or Position based addition?"
    Write-Host "       <DEFAULT:quit>"
    $choice = Read-Host "$ APS>"
    if($choice -eq "" -or $choice -eq $null)
    {
        $choice = "quit"
    }elseif($choice -like "department"){
        Write-Host "# APS> What Department?"
        Write-Host "       Available Departments:"
        foreach($x in $HT_MASTER.Keys)
        {
            Write-Host "       $x"
        }
        $CONTINUE = $false
        while($CONTINUE -ne $true)
        {
            $department = Read-Host "$ APS>"
            if($HT_MASTER.ContainsKey($department) -eq $true)
            {
                foreach($deptGroup in $HT_MASTER[$department]["GROUPS"])
                {
                    try{
                       Add-ADGroupMember $deptGroup $user
                       $GROUPS_ADDED = $GROUPS_ADDED + @($deptGroup)
                   }catch{
                       Write-Host "# APS> ERROR ADDING GROUP $deptGroup"
                   }
                }
                $CONTINUE = $true
            }else{
                Write-Host "# APS> INVALID DEPARTMENT"
            }
        }
    }elseif($choice -like "position"){
        Write-Host "# APS> What Department is the position in?"
        Write-Host "       Available Departments:"
        foreach($x in $HT_MASTER.Keys)
        {
            Write-Host "       $x"
        }
        $deptCONT = $false
        while($deptCONT -ne $true)
        {
            $department = Read-Host "$ APS>"
            if($HT_MASTER.ContainsKey($department) -eq $true)
            {
                $deptCONT = $true
            }else{
                Write-Host "# APS> INVALID DEPARTMENT"
            }
        }
        write-host "# APS> What Postion?"
        Write-Host "       Available Positions:"
        foreach($x in $HT_MASTER[$department]["POSITIONS"].Keys)
        {
            Write-Host "       $x"
        }
        $CONTINUE = $false
        while($CONTINUE -ne $true)
        {
            $position = Read-Host "$ APS>"
            if($HT_MASTER[$department]["POSITIONS"].ContainsKey($position) -eq $true)
            {
                foreach($posGroup in $HT_MASTER[$department]["POSITIONS"][$position]["GROUPS"])
                {
                    try{
                        Add-ADGroupMember $posGroup $user
                        $GROUPS_ADDED = $GROUPS_ADDED + @($posGroup)
                    }catch{
                        Write-Host "# APS> ERROR ADDING GROUP $posGroup"
                    }
                }
                $CONTINUE = $true
            }else{
                Write-Host "# APS> INVALID POSITION"
            }
        }
    }
}

##############################################################################
$Subject = "[PERMISSIONS ADDED] $($user.displayName)"
$Body = "
Username: $($user.SAMAccountName)
Display Name: $($user.displayName)
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
    Write-Host "# APS> EMAIL BODY START"
    write-host $Body
    Write-Host "# APS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
