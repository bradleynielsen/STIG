Param($computer)

#region:    Config

    $Vul_ID     = "63355"
    $TestName   = "Alternate operating systems"
    $CheckValue = "Microsoft Windows 10 Enterprise; \Device\HarddiskVolume2"
    $passFail   = ""

#endregion: Config

try{
    $results = Invoke-Command -ComputerName $computer -ScriptBlock {
        $caption    = Get-CimInstance Win32_OperatingSystem | Select-Object  -ExpandProperty Caption
        $BootDevice = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty BootDevice 
        "$caption; $BootDevice"
    } -ErrorAction stop
}catch{
    $results = "CIM unreachable"
}

if($results -eq $CheckValue){
    $passFail = "Pass"
}else{
    $passFail = "Fail"
}

if($results -eq "CIM unreachable"){
    $passFail = "N/A"
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
"Verify the system does not include other operating system installations.

Run ""Advanced System Settings"".
Select the ""Advanced"" tab.
Click the ""Settings"" button in the ""Startup and Recovery"" section.

If the drop-down list box ""Default operating system:"" shows any operating system other than Windows 10, this is a finding."

-----------------------------------------------------------------------------------------------
RNOSC-I:
"Run from an administrative PowerShell session replacing <Computer> with the remote hostname:

Get-WMIObject Win32_OperatingSystem | Measure | Select -Expand Count

If the result is greater than ""1"" then this is a finding."
#>