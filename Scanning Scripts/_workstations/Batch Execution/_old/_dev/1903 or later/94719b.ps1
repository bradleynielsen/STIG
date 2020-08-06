Param(
    $computer
)

#region:    Config

    $Vul_ID     = "94719b"
    $TestName   = "LetAppsActivateWithVoiceAboveLock"
    $CheckValue = "2"
    $passFail   = ""

#endregion: Config

#region:    Reg Path Config

    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $RegistryHive = 'HKEY_LOCAL_MACHINE'
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'
    $ValueNames    = 'LetAppsActivateWithVoiceAboveLock'
    $searchPath   = $searchPrefix+$RegistryHive+$RegistryPath

#endregion: Reg Path Config
        
$results = Invoke-Command -ComputerName $computer -ArgumentList {$searchPath,$ValueName} -ScriptBlock {
    try{
        (get-ItemProperty -path $using:searchPath -ErrorAction Stop).$using:ValueName            
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
    "Value"      = $results
    "Pass/Fail"  = $passFail
}

$resultsObj | Export-Csv -Path $PSScriptRoot\$Vul_ID" - "$datestamp" - results.csv" -Append -NoTypeInformation
return $resultsObj


 

 <#
 "This setting requires v1903 or later of Windows 10; it is NA for prior versions.  The setting is NA when the â€œAllow voice activationâ€ policy is configured to disallow applications to be activated with voice for all users.
If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\AppPrivacy\

Value Name: LetAppsActivateWithVoiceAboveLock

Type: REG_DWORD
Value: 0x00000002 (2)

If the following registry value exists and is configured as specified, requirement is NA. 

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\AppPrivacy\

Value Name: LetAppsActivateWithVoice

Type: REG_DWORD
Value: 0x00000002 (2)"

 #>