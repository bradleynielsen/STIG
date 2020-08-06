Param($computer)

#region:    Config
    $Vul_ID       = ''
    $TestName     = ''
    $RegistryHive = ''
    $RegistryPath = ''
    $ValueName    = ''      
    $ValueType    = ''
    $CheckValue   = ''

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

    if($results -eq $CheckValue){
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




#>