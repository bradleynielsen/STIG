Param($computer)

#region:    Config

    $Vul_ID       = '94861'
    $TestName     = 'Windows 10 systems must use a BitLocker PIN with a minimum length of 6 digits for pre-boot authentication.'
    $RegistryHive = 'HKEY_LOCAL_MACHINE'
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\FVE\'
    $ValueName    = 'MinimumPIN'
    $ValueType    = 'REG_DWORD'
    $CheckValue   = 6
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
    }elseif ($results -gt 6) {
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

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\FVE\

Value Name: MinimumPIN
Type: REG_DWORD
Value: 0x00000006 (6) or greater"








#>