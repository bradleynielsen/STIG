Param($computer)

#region:    Config
    $Vul_ID       = '74413'
    $TestName     = 'Windows 10 must be configured to prioritize ECC Curves with longer key lengths first.'
    $RegistryHive = 'HKEY_LOCAL_MACHINE'
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002\'
    $ValueName    = 'EccCurves'      
    $ValueType    = 'REG_MULTI_SZ'
    $CheckValue   = 'NistP384 NistP256'

    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $searchPath   = $searchPrefix+$RegistryHive+$RegistryPath
    $passFail     = ""

#endregion: Config

#region:    Scan

    try{
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
            $searchPath = $args[0]
            $ValueName  = $args[1]
            (get-ItemProperty -path $searchPath).$ValueName
        } -ArgumentList $searchPath,$ValueName -ErrorAction Stop
    }catch{
        $results  = "Error"
        $passFail = "Error"
    }

#endregion: Scan

#region:    Test

if($results -ne "Error"){
    if($results -join ' ' -eq $CheckValue){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
    }
}

#endregion: Test

#region:    Retrun Results

    $resultsObj = [PSCustomObject]@{
        "Computer"   = $computer
        "Vul_ID"     = $Vul_ID
        "Test Name"  = $TestName
        "CheckValue" = $CheckValue
        "Value"      = $results -join ' '
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
Registry Path: \SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002\

Value Name: EccCurves

Value Type: REG_MULTI_SZ
Value: NistP384 NistP256"



#>