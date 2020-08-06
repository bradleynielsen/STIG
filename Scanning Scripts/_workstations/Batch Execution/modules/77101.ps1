Param($computer)

#region:    Config

    $Vul_ID     = "77101"
    $TestName   = "Get-ProcessMitigation -System SEHOP.Enable"
    $CheckValue = "NOTSET","ON"
    $passFail   = ""

#endregion: Config

#region:    Scan

    try{
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
                    (Get-ProcessMitigation -System -WarningAction SilentlyContinue).SEHOP.Enable
        } -ErrorAction stop
        $results = $results.Value
    }catch{
        $results  = "Error"
        $passFail = "Error"
    }

#endregion: Scan

#region:    Test

if($results -ne "Error"){
    if($results -eq $CheckValue[0] -or $results -eq $CheckValue[1] ){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
    }
}

#endregion: Test


#region:    Return Results

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


#endregion: Return Results



<#
Check Content
<#
V-77091	
"This is NA prior to v1709 of Windows 10.
This is applicable to unclassified systems, for other systems this is NA.
The default configuration in Exploit Protection is ""On by default"" which meets this requirement.  The PowerShell query results for this show as ""NOTSET"".
Run ""Windows PowerShell"" with elevated privileges (run as administrator).
Enter ""Get-ProcessMitigation -System"".
If the status of ""DEP: Enable"" is ""OFF"", this is a finding.
Values that would not be a finding include:
ON
NOTSET (Default configuration)"

V-77095	
"This is NA prior to v1709 of Windows 10.
This is applicable to unclassified systems, for other systems this is NA.
The default configuration in Exploit Protection is ""On by default"" which meets this requirement.  The PowerShell query results for this show as ""NOTSET"".
Run ""Windows PowerShell"" with elevated privileges (run as administrator).
Enter ""Get-ProcessMitigation -System"".
If the status of ""ASLR: BottomUp"" is ""OFF"", this is a finding.
Values that would not be a finding include:
ON
NOTSET (Default configuration)"

V-77097	
"This is NA prior to v1709 of Windows 10.
This is applicable to unclassified systems, for other systems this is NA.
The default configuration in Exploit Protection is ""On by default"" which meets this requirement.  The PowerShell query results for this show as ""NOTSET"".
Run ""Windows PowerShell"" with elevated privileges (run as administrator).
Enter ""Get-ProcessMitigation -System"".
If the status of ""CFG: Enable"" is ""OFF"", this is a finding.
Values that would not be a finding include:
ON
NOTSET (Default configuration)"

V-77101	
"This is NA prior to v1709 of Windows 10.
This is applicable to unclassified systems, for other systems this is NA.
The default configuration in Exploit Protection is ""On by default"" which meets this requirement.  The PowerShell query results for this show as ""NOTSET"".
Run ""Windows PowerShell"" with elevated privileges (run as administrator).
Enter ""Get-ProcessMitigation -System"".
If the status of ""SEHOP: Enable"" is ""OFF"", this is a finding.
Values that would not be a finding include:
ON
NOTSET (Default configuration)"

V-77103	
"This is NA prior to v1709 of Windows 10.
This is applicable to unclassified systems, for other systems this is NA.
The default configuration in Exploit Protection is ""On by default"" which meets this requirement.  The PowerShell query results for this show as ""NOTSET"".
Run ""Windows PowerShell"" with elevated privileges (run as administrator).
Enter ""Get-ProcessMitigation -System"".
If the status of ""Heap: TerminateOnError"" is ""OFF"", this is a finding.
Values that would not be a finding include:
ON
NOTSET (Default configuration)"
#>