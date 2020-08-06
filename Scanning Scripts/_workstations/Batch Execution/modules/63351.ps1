Param($computer)

#region:    Config

    $Vul_ID     = "63351"
    $TestName   = "anti-virus program"
    $CheckValue = "McAfee Endpoint Security Platform"
    $passFail   = ""
    $stigCkCnt  = "Verify an anti-virus solution is installed on the system. The anti-virus solution may be bundled with an approved host-based security solution.

If there is no anti-virus solution installed on the system, this is a finding."


#endregion: Config

    
$results = Invoke-Command -ComputerName $computer -ScriptBlock {
    Get-WmiObject -Class Win32Reg_AddRemovePrograms | select DisplayName | ? -Property DisplayName -like "McAfee Endpoint Security Platform"| Select-Object -ExpandProperty displayname
} -ErrorAction SilentlyContinue

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
"Determine if a host-based firewall is installed and enabled on the system.  If a host-based firewall is not installed and enabled on the system, this is a finding.

The configuration requirements will be determined by the applicable firewall STIG."


#>