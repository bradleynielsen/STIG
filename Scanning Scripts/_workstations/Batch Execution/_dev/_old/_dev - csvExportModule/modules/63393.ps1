Param($computer)

#region:    Config

    $Vul_ID     = "63393"
    $TestName   = ".p12 .pfx files"
    $CheckValue = $null
    $passFail   = ""

#endregion: Config

$results = @(Invoke-Command -ComputerName $computer -ScriptBlock {
    ls -path c:\ -Recurse -Include "*.p12","*.pfx" -ErrorAction SilentlyContinue
} -ErrorAction SilentlyContinue)

foreach ($result in $results){
    if($result -eq $CheckValue -or $result.Name -eq "Preflight.p12" ){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
    }
}


$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue
    "Value"      = $results.Value.name -join ', '
    "Pass/Fail"  = $passFail
}

$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj

return $resultsObj

<#
Check Content
"Search all drives for *.p12 and *.pfx files.

If any files with these extensions exist, this is a finding.

This does not apply to server-based applications that have a requirement for .p12 certificate files (e.g., Oracle Wallet Manager) or Adobe PreFlight certificate files. 
Some applications create files with extensions of .p12 that are not certificate installation files. 
Removal of non-certificate installation files from systems is not required. 
These must be documented with the ISSO."

#>



