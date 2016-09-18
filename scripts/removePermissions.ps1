Write-Host "Remove Permissions Script"
$user = getExistingUser
$GROUPS_REMOVED = @()

Write-Host "# RPS> Remove all permission?"
Write-Host "       <DEFAULT:no>"
$rall = Read-Host "$ RPS>"
if($rall -eq "yes" -or $rall -eq "y")
{
    #REMOVE ALL GROUPS
    foreach($grp in $user.memberof)
    {
        $GROUPS_REMOVED = $GROUPS_REMOVED + @($grp)
        Remove-ADGroupMember -identity $grp -member $user -confirm:$false
    }
}else{
    $choice = ""
    while($choice -ne "quit" -and $choice -ne "q")
    {
        Write-Host "# RPS> Remove Permissions by Position or Department?"
        Write-host "       <DEFAULT:quit>"
        $choice = Read-Host "$ RPS>"
        if($choice -eq "" -or $choice -eq $null)
        {
            $choice = "quit"
        }elseif($choice -like "department"){
            Write-Host "# RPS> What Department do you want to remove roles for?"
            Write-Host "       Available Departments:"
            foreach($x in $HT_MASTER.Keys)
            {
                Write-Host "       $x"
            }
            $CONTINUE = $false
            while($CONTINUE -ne $true)
            {
                $department = Read-Host "$ RPS>"
                if($HT_MASTER.ContainsKey($department) -eq $true)
                {
                    foreach($deptGroup in $HT_MASTER[$department]["GROUPS"])
                    {
                        try{
                            Remove-ADGroupMember -identity $deptGroup -member $user -confirm:$false
                            $GROUPS_REMOVED = $GROUPS_REMOVED + @($deptGroup)
                        }catch{
                            Write-Host "ERROR REMOVING GROUP $deptGroup"
                        }
                    }
                    $CONTINUE = $true
                }else{
                    Write-Host "# RPS> INVALID DEPARTMENT"
                }
            }
        }elseif($choice -like "position"){
            Write-Host "# RPS> What Department is the positon in?"
            Write-Host "       Available Departments:"
            foreach($x in $HT_MASTER.Keys)
            {
                Write-Host "       $x"
            }
            $deptCONT = $false
            while($deptCONT -ne $true)
            {
                $department = Read-Host "$ RPS>"
                if($HT_MASTER.ContainsKey($department) -eq $true)
                {
                    $deptCONT = $true
                }else{
                    Write-Host "# RPS> INVALID DEPARTMENT"
                }
            }
            Write-Host "# RPS> What Position?"
            Write-Host "       Available Positions:"
            foreach($x in $HT_MASTER[$department]["POSITIONS"].Keys)
            {
                Write-Host "       $x"
            }
            $CONTINUE = $false
            while($CONTINUE -ne $true)
            {
                $position = Read-Host "$ RPS> Position"
                if($HT_MASTER[$department]["POSITIONS"].ContainsKey($position) -eq $true)
                {
                    foreach($posGroup in $HT_MASTER[$department]["POSITIONS"][$position]["GROUPS"])
                    {
                        try{
                            Remove-ADGroupMember -identity $posGroup -member $user -confirm:$false
                            $GROUPS_REMOVED = $GROUPS_REMOVED + @($posGroup)
                        }catch{
                            Write-Host "# RPS> ERROR REMOVING GROUP $posGroup"
                        }
                    }
                    $CONTINUE = $true
                }else{
                    Write-Host "# RPS> INVALID POSITION"
                }
            }
        }
    }
}

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
===
- START FULL ACCOUNT INFO
===
$($user | Out-String)
===
- END FULL ACCOUNT INFO
===
"
if($EMAIL_IN_OUPUT){
    Write-Host "# RPS> EMAIL BODY START"
    write-host $Body
    Write-Host "# RPS> EMAIL BODY START"
}
Send-MailMessage -From $EMAIL_FROM -to $EMAIL_TO -Cc $EMAIL_CC -Subject $Subject -Body $Body -SmtpServer $EMAIL_EXCHANGE_SERVER
##############################################################################
