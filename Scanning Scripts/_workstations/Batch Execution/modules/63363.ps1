Param($computer)

#region:    Config

    $Vul_ID         = "63363"
    $TestName       = "Backup Operators"
    $CheckValue     = 0
    $passFail       = ""
    $failures       = @()

#endregion: Config

#region:    Scan

    try{
        $results = Get-WMIObject Win32_GroupUser -Filter "GroupComponent=""Win32_Group.Domain='$computer',Name='Backup Operators'""" | foreach { if ($_.PartComponent -match 'Domain="(.+)",Name="(.+)"') { "$($Matches[1])\$($Matches[2])" } }
    }catch{
        $results = "Error"
    }

#endregion: Scan

#region:    Test Results


    if ($results -like "*error*") {
        $passFail = "Error"
    } elseif ($results.count -eq $CheckValue) {
        $passFail = "Pass"
    } else {
        foreach($result in $results){
            $failures += $result
        }
    }

    if($failures){
        $results = $failures
        $passFail = "Fail"
    }

#endregion: Test Results

$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue
    "Value"      = $results -join ', '
    "Pass/Fail"  = $passFail
}

$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj
return $resultsObj

<#

Check Content
"Run ""Computer Management"".
Navigate to System Tools >> Local Users and Groups >> Groups.
Review the members of the Backup Operators group.

If the group contains no accounts, this is not a finding.

If the group contains any accounts, the accounts must be specifically for backup functions.

If the group contains any standard user accounts used for performing normal user tasks, this is a finding."

Automated Check Development Notes
"Run from an administrative PowerShell session replacing <Computer> with the remote hostname:

$Members = Get-WMIObject Win32_GroupUser -Filter ""GroupComponent=""""Win32_Group.Domain='<Computer>',Name='Backup Operators'"""""" | foreach { if ($_.PartComponent -match 'Domain=""(.+)"",Name=""(.+)""') { ""$($Matches[1])\$($Matches[2])"" } }

This will display all members of the local security group ""Backup Operators."" If there are no members, the result will return null and this will not be a finding. If any users are returned, they must meet the STIG criteria to belong to this group for this to not be a finding."



#>
