Param($computer)

#region:    Config
    $Vul_ID       = "63545"
    $TestName     = "Camera access from the lock screen must be disabled." 
    $RegistryHive = 'HKEY_LOCAL_MACHINE'                                    
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\Windows\Personalization\'
    $ValueName    = 'NoLockScreenCamera'                                           
    $ValueType    = 'REG_DWORD'                                             
    $CheckValue   = "1"                                                      

    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $searchPath   = $searchPrefix+$RegistryHive+$RegistryPath
    $passFail     = ""

#endregion: Config

#region:    Scan

    $results = Invoke-Command -ComputerName $computer -ScriptBlock {
        $searchPath = $args[0]
        $ValueName  = $args[1]
        (get-ItemProperty -path $searchPath).$ValueName
    } -ArgumentList $searchPath,$ValueName

#endregion: Scan


#region:    Test Results

    if($results -eq $CheckValue){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
        $results  = Get-WMIObject Win32_Share -ComputerName $computer -ErrorAction SilentlyContinue | where {$_.Name -notmatch '^Admin\$$|^IPC\$$|^[A-Z]\$$'}
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


"If the device does not have a camera, this is NA.

If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\Personalization\

Value Name: NoLockScreenCamera

Value Type: REG_DWORD
Value: 1"


    (get-ItemProperty -path $using:searchPath).$ValueName


#>