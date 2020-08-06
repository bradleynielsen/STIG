Param($computer)
#region:    Config

    $Vul_ID     = "63361"
    $TestName   = "Get-AppLockerPolicy EnforcementMode"
    $passFail   = ""
    $CheckValue = "Alias name     administrators
Comment        

Members

-------------------------------------------------------------------------------
DoD_Admin
SWA\IRQ-GS-BDSC-Help_Desk
SWA\IRQ-GS-BDSC-IA
SWA\IRQ-GS-BDSC-IMO
SWA\IRQ-GS-BDSC-NA
SWA\IRQ-GS-BDSC-Site_Admin
SWA\SWA Domain Service Accounts
SWA\SWA Domain Workstation Admins
SWA_AD
SWA_Admin
The command completed successfully.

"



#endregion: Config

$results = Invoke-Command -ComputerName $computer -ScriptBlock {
    net localgroup administrators
} -ErrorAction SilentlyContinue

if(($results| Out-String) -eq ($CheckValue)){
    $passFail = "Pass"
}else{
    $passFail = "Fail"
}

$results = ($results| Out-String)

$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue 
    "Value"      = $results
    "Pass/Fail"  = $passFail
}

$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj

return $resultsObj


<#
Check Content

"Run ""Computer Management"".
Navigate to System Tools >> Local Users and Groups >> Groups.
Review the members of the Administrators group.
Only the appropriate administrator groups or accounts responsible for administration of the system may be members of the group.

For domain-joined workstations, the Domain Admins group must be replaced by a domain workstation administrator group.

Standard user accounts must not be members of the local administrator group.

If prohibited accounts are members of the local administrators group, this is a finding.

The built-in Administrator account or other required administrative accounts would not be a finding."


#>

















"Alias name     administrators
Comment        

Members

-------------------------------------------------------------------------------
DoD_Admin
SWA\IRQ-GS-BDSC-Help_Desk
SWA\IRQ-GS-BDSC-IA
SWA\IRQ-GS-BDSC-IMO
SWA\IRQ-GS-BDSC-NA
SWA\IRQ-GS-BDSC-Site_Admin
SWA\SWA Domain Service Accounts
SWA\SWA Domain Workstation Admins
SWA_AD
SWA_Admin
The command completed successfully.



"




