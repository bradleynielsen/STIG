Param($computer)

#region:    Config

    $Vul_ID     = "63357"
    $TestName   = "Win32_Share"
    $CheckValue = 0
    $passFail   = ""

#endregion: Config

$results = Get-WMIObject Win32_Share -ComputerName $computer -ErrorAction SilentlyContinue | where {$_.Name -notmatch '^Admin\$$|^IPC\$$|^[A-Z]\$$'} | Measure | Select -Expand Count 

        if ($results -eq $null){
            $test = "NULL"
        }elseif($results.ToString() -eq $value){
            $test = "Pass"
        }else{
            $test = "Fail"
        }

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

<#
Check Content
63357
"Non system-created shares should not typically exist on workstations.

If only system-created shares exist on the system this is NA.

Run ""Computer Management"".
Navigate to System Tools >> Shared Folders >> Shares.

If the only shares listed are ""ADMIN$"", ""C$"" and ""IPC$"", this is NA.
(Selecting Properties for system-created shares will display a message that it has been shared for administrative purposes.)

Right click any non-system-created shares.
Select ""Properties"".
Select the ""Share Permissions"" tab.

Verify the necessity of any shares found.
If the file shares have not been reconfigured to restrict permissions to the specific groups or accounts that require access, this is a finding.

Select the ""Security"" tab.

If the NTFS permissions have not been reconfigured to restrict permissions to the specific groups or accounts that require access, this is a finding."


#>
