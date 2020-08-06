Param($computer)
#region:    Config

    $Vul_ID     = "63323"
    $TestName   = "TPM enabled"
    $CheckValue = "True"
    $passFail   = ""

#endregion: Config

try{
    $results = Invoke-Command -ComputerName $computer -ScriptBlock {
        return (Get-WMIObject Win32_TPM -Namespace root\CIMv2\Security\MicrosoftTpm).IsReady().IsReady
    } -ErrorAction stop
}catch{
    $results = "Error"
}


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
Check Content
"Verify domain-joined systems have a TPM enabled and ready for use.

For standalone systems, this is NA.

Virtualization based security, including Credential Guard, currently cannot be implemented in virtual desktop implementations (VDI) due to specific supporting requirements including a TPM, UEFI with Secure Boot, and the capability to run the Hyper-V feature within the virtual desktop.

For VDIs where the virtual desktop instance is deleted or refreshed upon logoff, this is NA.

Verify the system has a TPM and is ready for use.
Run ""tpm.msc"".
Review the sections in the center pane.
""Status"" must indicate it has been configured with a message such as ""The TPM is ready for use"" or ""The TPM is on and ownership has been taken"".
TPM Manufacturer Information - Specific Version = 2.0 or 1.2

If a TPM is not found or is not ready for use, this is a finding."

#>