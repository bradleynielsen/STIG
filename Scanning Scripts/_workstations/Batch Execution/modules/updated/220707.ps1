Param($computer)

#region:    Config
    $STIG_Version = 'Windows 10 Security Technical Implementation Guide :: Version 2, Release: 2 Benchmark Date: 04 May 2021'
    $Vul_ID       = "220707"
    $TestName     = "anti-virus program"
    $CheckValue   = "McAfee Endpoint Security Platform"
    $passFail     = ""
    $stigCkCnt    = "Verify an anti-virus solution is installed on the system. The anti-virus solution may be bundled with an approved host-based security solution.

If there is no anti-virus solution installed on the system, this is a finding."


#endregion: Config

    
$results = Invoke-Command -ComputerName $computer -ScriptBlock {
    Get-WmiObject -Class Win32Reg_AddRemovePrograms | select DisplayName | ? -Property DisplayName -like "McAfee Endpoint Security Platform"| Select-Object -ExpandProperty displayname
} -ErrorAction SilentlyContinue

if($results -eq $CheckValue){
    $passFail = "Pass"
}else{
    $passFail = "Fail"
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
Check Text: Verify an anti-virus solution is installed on the system and in use. The anti-virus solution may be bundled with an approved host-based security solution.

Verify if Windows Defender is in use or enabled:

Open "PowerShell".

Enter “get-service | where {$_.DisplayName -Like "*Defender*"} | Select Status,DisplayName”

Verify third-party antivirus is in use or enabled:

Open "PowerShell".

Enter “get-service | where {$_.DisplayName -Like "*mcafee*"} | Select Status,DisplayName”

Enter “get-service | where {$_.DisplayName -Like "*symantec*"} | Select Status,DisplayName”

If there is no anti-virus solution installed on the system, this is a finding.

Fix Text: If no anti-virus software is in use, install Windows Defender or a third-party anti-virus solution.



#>