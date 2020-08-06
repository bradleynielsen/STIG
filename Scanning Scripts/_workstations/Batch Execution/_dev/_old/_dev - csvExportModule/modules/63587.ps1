Param($computer)

#region:    Config

    $Vul_ID     = "63587"
    $TestName   = "DoD Interoperability certs"
    $CheckValue = !$null
    $passFail   = ""

#endregion: Config

#region:    Functions

    function checkValueNull {
        param($inputValue)
        if ($inputValue -ne $null){
            return "Pass"
        }else{
            return "Fail"        
        }
    }

#endregion: Functions



$results = Invoke-Command -ComputerName $computer -ScriptBlock {
    Get-ChildItem -Path Cert:Localmachine\disallowed | 
    Where {$_.Issuer -Like "*DoD Interoperability*" -and $_.Subject -Like "*DoD*"}
} -ErrorAction SilentlyContinue
        
foreach ($result in $results){
    #Testing for null values check:
    $subject    = checkValueNull -inputValue $result.Subject 
    $Issuer     = checkValueNull -inputValue $result.Issuer 
    $Thumbprint = checkValueNull -inputValue $result.Thumbprint 
    $NotAfter   = checkValueNull -inputValue $result.NotAfter 

    #Evaluate computer pass/fail status
    if(
        $subject    -eq "Pass" -and 
        $Issuer     -eq "Pass" -and 
        $Thumbprint -eq "Pass" -and 
        $NotAfter   -eq "Pass" -and
        $passFail   -ne "Fail" 
    ){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
    }
}

$resultsObj = [PSCustomObject]@{
    "Computer"           = $computer
    "Vul_ID"             = $Vul_ID
    "Test Name"          = $TestName
    "CheckValue"         = $CheckValue
    "Value"              = $results -join ', '
    "Subject (value)"    = ($Subject+": "+$result.Subject)
    "Issuer (value)"     = ($Issuer+": "+$result.Issuer)
    "Thumbprint (value)" = ($Thumbprint+": "+$result.Thumbprint)
    "NotAfter (value)"   = ($NotAfter+": "+$result.NotAfter)
    "Pass/Fail"          = $passFail
}

$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj

return $resultsObj
<#
Check Content


#>