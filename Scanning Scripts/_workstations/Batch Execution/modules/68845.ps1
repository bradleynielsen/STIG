Param($computer)

#region:    Config

    $Vul_ID     = "68845"
    $TestName   = "DEP configuration"
    $CheckValue = "nxAlwaysOn","nxOptOut"
    $passFail   = ""

#endregion: Config

#region:    Scan

    try{
        $results = (Invoke-Command -ComputerName $computer -ScriptBlock {
            BCDEdit /enum "{current}"
        } -ErrorAction stop)[18].Replace(" ","")
    } catch {
        $results = "Invoke-Command Error: "+$error[0].CategoryInfo.Reason
    }

#endregion: Scan

if($results -eq $CheckValue[0] -or $results -eq $CheckValue[1] ){
    $passFail = "Pass"
}else{
    $passFail = "Fail"
}

$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue -join ', '
    "Value"      = $results -join ', '
    "Pass/Fail"  = $passFail
}

$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj

return $resultsObj

<#
Check Content
""Verify the DEP configuration.
Open a command prompt (cmd.exe) or PowerShell with elevated privileges (Run as administrator).
Enter ""BCDEdit /enum {current}"". (If using PowerShell ""{current}"" must be enclosed in quotes.)
If the value for ""nx"" is not ""OptOut"", this is a finding.
(The more restrictive configuration of ""AlwaysOn"" would not be a finding.)"

#>