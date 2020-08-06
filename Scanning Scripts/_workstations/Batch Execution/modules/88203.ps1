Param($computer)

#region:    Config

    $Vul_ID       = '88203'
    $TestName     = 'OneDrive must only allow synchronizing of accounts for DoD organization instances.'
    $RegistryHive = 'HKEY_LOCAL_MACHINE'
    $RegistryPath = '\SOFTWARE\Policies\Microsoft\OneDrive\AllowTenantList\'
    $ValueName    = '1111-2222-3333-4444'      
    $ValueType    = 'REG_SZ'
    $CheckValue   = '1111-2222-3333-4444'
    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $searchPath   = $searchPrefix+$RegistryHive+$RegistryPath
    $passFail     = ""
    $condition    = 'Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\OneDrive'

#endregion: Config

#region:    Scan
    try{
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
                        $searchPath = $args[0]
                        $ValueName  = $args[1]
                        $condition  = $args[2]
                        if(Test-Path $condition){ #if onedrive exists, test the value
                            $results = (get-ItemProperty -path $searchPath -ErrorAction SilentlyContinue ).$ValueName
                        }else{# else, mark as not found
                            $results = "Not Found"
                        }
                            return $results
                    } -ArgumentList $searchPath,$ValueName,$condition -ErrorAction Stop
    }catch{
        $results = "Invoke-Command Error: "+$error[0].CategoryInfo.Reason
    }finally{
        
    
    }

#endregion: Scan


#region:    Test Results

    if ($results -eq $CheckValue) {
        $passFail = "Pass"
    }elseif ($results -eq "Not Found") {
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

"If the organization is using a DoD instance of OneDrive, verify synchronizing is only allowed to the organization's DoD instance.

If the organization does not have an instance of OneDrive, verify this is configured with the noted dummy entry to prevent synchronizing with other instances.

If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\OneDrive\AllowTenantList\

Value Name: Organization's Tenant GUID

Value Type: REG_SZ
Value: Organization's Tenant GUID

If the organization does not have an instance of OneDrive the Value Name and Value must be 1111-2222-3333-4444, if not this is a finding."




#>