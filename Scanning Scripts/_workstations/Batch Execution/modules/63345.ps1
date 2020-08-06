Param($computer)

#region:    Config

    $Vul_ID     = "63345"
    $TestName   = "Get-AppLockerPolicy EnforcementMode"
    $CheckValue = "Enabled","Enabled","Enabled","Enabled","Enabled"
    $passFail   = ""

#endregion: Config

$results = Invoke-Command -ComputerName $computer -ScriptBlock {
    (Get-AppLockerPolicy -Effective | Select-Object -ExpandProperty RuleCollections).EnforcementMode 
} -ErrorAction SilentlyContinue

for($i=0; $i -lt $results.count; $i++){
    if($results[$i].Value -eq $CheckValue[$i]){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
    }
}

$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue -join ', '
    "Value"      = $results.Value -join ', '
    "Pass/Fail"  = $passFail
}


$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj

return $resultsObj

<#
Check Content

"This is applicable to unclassified systems; for other systems this is NA.

Verify the operating system employs a deny-all, permit-by-exception policy to allow the execution of authorized software programs. This must include packaged apps such as the universals apps installed by default on systems.

If an application whitelisting program is not in use on the system, this is a finding.

Configuration of whitelisting applications will vary by the program.

AppLocker is a whitelisting application built into Windows 10 Enterprise.  A deny-by-default implementation is initiated by enabling any AppLocker rules within a category, only allowing what is specified by defined rules.

If AppLocker is used, perform the following to view the configuration of AppLocker:
Run ""PowerShell"".

Execute the following command, substituting [c:\temp\file.xml] with a location and file name appropriate for the system:
Get-AppLockerPolicy -Effective -XML > c:\temp\file.xml

This will produce an xml file with the effective settings that can be viewed in a browser or opened in a program such as Excel for review.

Implementation guidance for AppLocker is available in the NSA paper ""Application Whitelisting using Microsoft AppLocker"" at the following link:

https://www.iad.gov/iad/library/ia-guidance/tech-briefs/application-whitelisting-using-microsoft-applocker.cfm"

#>