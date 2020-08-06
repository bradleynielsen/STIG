Param($computer)

$computer ="BDSCNBN160S1E1D"


#region:    Config

    $Vul_ID       = '99563'
    $TestName     = 'Windows spotlight features may suggest apps and content from third-party software publishers in addition to Microsoft apps and content.'
    $RegistryHive = 'HKEY_CURRENT_USER'
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\Windows\CloudContent\'
    $ValueName    = 'DisableThirdPartySuggestions'
    $ValueType    = 'REG_DWORD'
    $CheckValue   = 1
    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $searchPath   = $searchPrefix+$RegistryHive+$RegistryPath
    $passFail     = ""

#endregion: Config

#region:    Scan

    try{
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
            $searchPath = $args[0]
            $ValueName  = $args[1]
            $results = (get-ItemProperty -path $searchPath -ErrorAction SilentlyContinue ).$ValueName
            return $results
        } -ArgumentList $searchPath,$ValueName -ErrorAction Stop
    } catch {
        $results = "Invoke-Command Error: "+$error[0].CategoryInfo.Reason
    }

#endregion: Scan

#region:    Test Results

    if ($results -like "*error*") {
        $passFail = "Error"
    }elseif ($results -eq $CheckValue) {
        $passFail = "Pass"
    } else {
        $passFail = "Fail"
    }

#endregion: Test Results

#region:    Retrun Results

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

#endregion: Retrun Results



<#
Check Content


"If the following registry value does not exist or is not configured as specified, this is a finding.

If the following registry value does not exist or is not configured as specified, this is a finding: 

Registry Hive: HKEY_CURRENT_USER
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\CloudContent\

Value Name: DisableThirdPartySuggestions

Type: REG_DWORD
Value: 0x00000001 (1)

"









#>