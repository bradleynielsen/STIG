Param($computer)


#region:    Config

    $Vul_ID     = "76505"
    $TestName   = "Local Group Policy Editor User Rights"
    $CheckValue = $null
    $passFail   = ""

#endregion: Config

try{
    $results = (Get-WMIObject RSOP_UserPrivilegeRight -Namespace root\RSOP\Computer -ComputerName $computer -ErrorAction Stop | where {$_.AccountList -match '^S-1-5-21'} | Select UserRight, AccountList ) 
}catch{
    $results = "Error"
}

if($results -eq $CheckValue){
    $passFail = "Pass"
}else{
    $passFail = "Fail"
}

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
"Review the effective User Rights setting in Local Group Policy Editor.
Run ""gpedit.msc"".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> User Rights Assignment.

Review each User Right listed for any unresolved SIDs to determine whether they are valid, such as due to being temporarily disconnected from the domain. (Unresolved SIDs have the format of ""*S-1-â€¦"".)

If any unresolved SIDs exist and are not for currently valid accounts or groups, this is a finding."


#>