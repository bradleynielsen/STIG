Param($computer)
$computer = 'BDSCWKNAEAS7064'

#region:    Config
    $Vul_ID       = '63839'
    $TestName     = 'Toast notifications to the lock screen must be turned off.'
    $RegistryHive = 'HKEY_CURRENT_USER'
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications\'
    $ValueName    = 'NoToastApplicationNotificationOnLockScreen'      
    $ValueType    = 'REG_DWORD'
    $CheckValue   = '1'

    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $searchPath   = $searchPrefix+$RegistryHive+$RegistryPath
    $passFail     = ""

#endregion: Config

#region:    Scan

    $results = Invoke-Command -ComputerName $computer -ScriptBlock {
        $searchPath = $args[0]
        $ValueName  = $args[1]
        (get-ItemProperty -path $searchPath -ErrorAction SilentlyContinue).$ValueName
    } -ArgumentList $searchPath,$ValueName

#endregion: Scan


#region:    Test Results

    if ($results -eq $null){
        $passFail = "Fail"
    }elseif($results.ToString() -eq $CheckValue){
        $passFail = "Pass"
    }else{
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

"If the following registry value does not exist or is not configured as specified, this is a finding:

Registry Hive: HKEY_CURRENT_USER
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications\

Value Name: NoToastApplicationNotificationOnLockScreen

Value Type: REG_DWORD
Value: 1"



#>