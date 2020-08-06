Param($computer)

#region:    Config

    $Vul_ID     = "63739"
    $TestName   = "Reg: RestrictAnonymousSAM"
    $CheckValue = "1"
    $passFail   = ""

#endregion: Config
       
$results = Invoke-Command -ComputerName $computer -ArgumentList {$searchPath,$ValueName} -ScriptBlock {
    try{
        (get-itemproperty "HKLM:\System\CurrentControlSet\Control\LSA").RestrictAnonymousSAM        
    }catch{
            Write-Host "WinRM Failure" -ForegroundColor Red
            "WinRM Failure"
    }
            
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

"Verify the effective setting in Local Group Policy Editor.
Run ""gpedit.msc"".

Navigate to Local Computer Policy >> Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> Security Options.

If the value for ""Network access: Allow anonymous SID/Name translation"" is not set to ""Disabled"", this is a finding."


Run from an administrative PowerShell session replacing <Computer> with the remote hostname:

Invoke-Command -ComputerName <Hostname> -ScriptBlock {(get-itemproperty "HKLM:\System\CurrentControlSet\Control\LSA").RestrictAnonymousSAM}

If the returned value is not 1, this is a finding.


#>


