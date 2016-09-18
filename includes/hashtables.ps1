<#
MAIN MENU Available Commands

    command = script location
#>

$HT_COMMANDS = @{
    "Create" = "scripts/create.ps1"
    "Modify" = "scripts/modify.ps1"
    "Add Permissions" = "scripts/addPermissions.ps1"
    "Remove Permissions" = "scripts/removePermissions.ps1"
    "Expire" = "scripts/expire.ps1"
    "Disable" = "scripts/disable.ps1"
    "Enable" = "scripts/enable.ps1"
    "Unlock" = "scripts/unlock.ps1"
    "Terminate" = "scripts/terminate.ps1"
    "Quit" = "Exit The Script"
}

<#
EXCHANGE MAILBOX DATABASES

    database = description
#>

$HT_MX_DATABASE = @{
    "default" = "Size: 5GB - STOP SEND: 5.1GB - STOP RECIEVE: 5.5GB"
    "PowerUsers" = "Size: Unlimited"
    "none" = "No Mailbox Provided To The User"
}

<#
DEFAULT EXTENSIONS

#>

$HT_DEFAULT_EXT = @{
    "LOCATION" = @{
        "CORPORATE" = "0000"
        "BRANCH1" = "1000"
        "BRANCH2" = "2000"
    }
    "POSITION" = @{
        "Help Desk" = "0550"
    }
}

<#
LOCATIONS

NOT ACTUALLY A HASHTABLE....

#>

$HT_LOCATIONS = @{
    "Corporate" = "CORPORATE"
    "Branch1" = "BRANCH1"
    "Branch2" = "BRANCH2"
}

<#

DEPARTMENT = hashtable
    OU = string
    GROUPS = list of strings
    EXT = "LOCATION" OR "POSITION" OR EMPTY
    POSITIONS = hashtable
        OU = string
        GROUPS = list of strings

#>

$HT_MASTER = @{
    "STATIC_POSITIONS" = @{
        "GROUPS" = @(
        )
        "POSITIONS" = @{
            "BCP Team" = @{
                "GROUPS" = @(
                )
            }
            "info mailbox" = @{
                "GROUPS" = @(
                    "MAILBOX_INFO_FULLCONTROL"
                    "MAILBOX_INFO_SENDAS"
                )
            }
        }
    }
    "Admin" = @{
        "OU" = "OU=Admin,"
        "GROUPS" = @(
            "admins"
        )
        "EXT" = "POSITION"
        "POSITIONS" = @{
            "Officer" = @{
                "OU" = "OU=Officer,"
                "GROUPS" = @(
                    "officers"
                )
            }
            "Help Desk" = @{
                "OU" = "OU=Help Desk,"
                "GROUPS" = @(
                    "helpdesk"
                )
            }
            "Analyst" = @{
                "OU" = "OU=Analyst,"
                "GROUPS" = @(
                )
            }
        }
    }
    "DEPT1" = @{
        "OU" = "OU=DEPT1,"
        "GROUPS" = @(
        )
        "EXT" = "LOCATION"
        "POSITIONS" = @{
            "Job1" = @{
                "OU" = ""
                "GROUPS" = @(
                )
            }
            "Job2" = @{
                "OU" = ""
                "GROUPS" = @(
                )
            }
            "Job3" = @{
                "OU" = ""
                "GROUPS" = @(
                )
            }
        }
    }
}

<#
ALL GROUPS
DO NOT EDIT THIS
#>
$HT_DEPTGROUPS = @()
$HT_POSTGROUPS = @()
foreach($dept in $HT_MASTER.Keys)
{
    if($dept -notlike "STATIC_POSITIONS")
    {
        foreach($group in $HT_MASTER[$dept]["GROUPS"])
        {
            $HT_DEPTGROUPS = $HT_DEPTGROUPS + $($group)
        }

        foreach($position in $HT_MASTER[$dept]["POSITIONS"].Keys)
        {
            foreach($group in $HT_MASTER[$dept]["POSITIONS"][$position]["GROUPS"])
            {
                $HT_POSTGROUPS = $HT_POSTGROUPS + @($group)
            }
        }
    }
}
$HT_ALLGROUPS = $HT_DEPTGROUPS + $HT_POSTGROUPS
