Param($computer)

#region:    Config

    $Vul_ID       = '77085'
    $TestName     = 'Confirm-SecureBootUEFI'
    $CheckValue   = "True"
    $passFail     = ""

#endregion: Config

#region:    Scan

    try {
        $results = Invoke-Command -ComputerName $computer -ErrorAction Stop -ScriptBlock  {
            Confirm-SecureBootUEFI
        } -ArgumentList $CheckValue 
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


"Some older systems may not have UEFI firmware. This is currently a CAT III; it will be raised in severity at a future date when broad support of Windows 10 hardware and firmware requirements are expected to be met. Devices that have UEFI firmware must have Secure Boot enabled. 

For virtual desktop implementations (VDIs) where the virtual desktop instance is deleted or refreshed upon logoff, this is NA.

Run ""System Information"".

Under ""System Summary"", if ""Secure Boot State"" does not display ""On"", this is finding."






#>