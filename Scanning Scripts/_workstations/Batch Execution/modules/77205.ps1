﻿Param($computer)

#region:    Config

    $Vul_ID        = "77205"
    $TestName      = "Get-ProcessMitigation -Name"
    $appName       = 'firefox.exe'
    $CheckValue    = @("DEP.overridedep.False;ASLR.ForceRelocateImages.ON".Split(";"))   
    $passFail      = ""
    $testArray     = @()
    $resultsArray  = @()

#endregion: Config

#region:    Scan

    foreach ($index in $CheckValue){
                        
        $class    = $index.Split(".")[0]
        $property = $index.Split(".")[1]
        $value    = $index.Split(".")[2]
        "Testing $class.$property.$value"
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
                        $appName  = $args[0]
                        $class    = $args[1]
                        $property = $args[2]
                        $value    = $args[3]
                        (Get-ProcessMitigation -Name $appName -WarningAction SilentlyContinue).$class.$property
                    } -ArgumentList $appName, $class, $property, $value -ErrorAction SilentlyContinue
    
        if ($results -eq $null){
            $test = "NULL"
        }elseif($results.ToString() -eq $value){
            $test = "Pass"
        }else{
            $test = "Fail"
        }

        $resultsArray += "$class.$property"+": "+$results+" ["+$test+"]"
    }

    $resultsArray

    if(($resultsArray -match "Fail").Count -gt 0){
        $passFail = "Fail"
    }elseif(($resultsArray -match "Fail").Count -eq 0){
        $passFail = "Pass"
    }

#endregion: Scan
                        
#region:  Results

    $resultsObj = [PSCustomObject]@{
        "Computer"   = $computer
        "Vul_ID"     = $Vul_ID
        "Test Name"  = $TestName
        "CheckValue" = $CheckValue -join ','
        "Value"      = $resultsArray -join ','
        "Pass/Fail"  = $passFail
    }

    $exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
    & $exportCSV -resultsObj $resultsObj

    return $resultsObj

#endregion:    Return Results
<#
Check Content

"This is NA prior to v1709 of Windows 10.

This is applicable to unclassified systems, for other systems this is NA.

Run ""Windows PowerShell"" with elevated privileges (run as administrator).

Enter ""Get-ProcessMitigation -Name firefox.exe"".
(Get-ProcessMitigation can be run without the -Name parameter to get a list of all application mitigations configured.)
If the following mitigations do not have the listed status which is shown below, this is a finding:

DEP:
Override DEP: False

ASLR:
ForceRelocateImages: True

The PowerShell command produces a list of mitigations; only those with a required status are listed here. If the PowerShell command does not produce results, ensure the letter case of the filename within the command syntax matches the letter case of the actual filename on the system."





#>