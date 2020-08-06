Param($computer)

#region:    Config

    $Vul_ID       = '63685'
    $TestName     = 'EnableSmartScreen'
    $RegistryHive = 'HKEY_LOCAL_MACHINE'
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\Windows\System\'
    $ValueNames   = 'EnableSmartScreen','ShellSmartScreenLevel'  
    $ValueType    = 'REG_DWORD','REG_SZ'
    $CheckValues  = '1','Block'
    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $searchPath   = $searchPrefix+$RegistryHive+$RegistryPath
    $passFail     = ""

#endregion: Config

#region:    Scan
    try {
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
            $searchPath = $args[0]
            $ValueNames = $args[1]
            $results    = @()
            foreach($ValueName in $ValueNames){
                $results += (get-ItemProperty -path $searchPath -ErrorAction SilentlyContinue).$ValueName
            }
            $results
        } -ArgumentList $searchPath,$ValueNames -ErrorAction Stop
    } catch {
        $results = "Error"
    }


#endregion: Scan


#region:    Test Results
    
    $n = 0

    foreach($result in $results){
        if($result -like "*error*"){
            $passFail = "Error"
        }elseif($result -eq $CheckValues[$n]){
            $passFail = "Pass"
        } else {
            $passFail = "Fail"
        }
        $n ++
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

"This is applicable to unclassified systems, for other systems this is NA.

If the following registry values do not exist or are not configured as specified, this is a finding:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\System\

Value Name: EnableSmartScreen

Value Type: REG_DWORD
Value: 0x00000001 (1)

And

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\System\

Value Name: ShellSmartScreenLevel

Value Type: REG_SZ
Value: Block

v1607 LTSB:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\System\

Value Name: EnableSmartScreen

Value Type: REG_DWORD
Value: 0x00000001 (1)

v1507 LTSB:

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\System\

Value Name: EnableSmartScreen

Value Type: REG_DWORD
Value: 0x00000002 (2)"



#>