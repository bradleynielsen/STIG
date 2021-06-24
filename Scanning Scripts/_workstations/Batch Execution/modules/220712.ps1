Param($computer)

#region:    Config
    $STIG_Version = 'Windows 10 Security Technical Implementation Guide :: Version 2, Release: 2 Benchmark Date: 04 May 2021'
    $Vul_ID       = "220712"
    $TestName     = "Get-AppLockerPolicy EnforcementMode"
    $passFail     = ""
    $CheckValue   = "Alias name     administrators 
Comment        

Members

-------------------------------------------------------------------------------
account 1
account 2
etc...

"
# ^ set this to expected output


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














