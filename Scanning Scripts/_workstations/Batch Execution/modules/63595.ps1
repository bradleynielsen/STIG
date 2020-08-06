Param($computer)

#region:    Config

    $Vul_ID     = "63595"
    $TestName   = "Device Guard Required Security Properties"
    $CheckValue = @(1,2,2)
    $passFail   = ""
    $stigCkCnt  = ""

#endregion: Config
    
$results = Invoke-Command -ComputerName $computer -ScriptBlock {
    Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard| select RequiredSecurityProperties -ExpandProperty RequiredSecurityProperties
    Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard| select VirtualizationBasedSecurityStatus -ExpandProperty VirtualizationBasedSecurityStatus
} -ErrorAction SilentlyContinue

$CheckValue = $CheckValue |Out-String
$results    = $results    |Out-String

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

"Confirm Virtualization Based Security is enabled and running with Secure Boot or Secure Boot and DMA Protection.

For those devices that support virtualization based security (VBS) features, including Credential Guard or protection of code integrity, this must be enabled. If the system meets the hardware and firmware dependencies for enabling VBS but it is not enabled, this is a CAT III finding.

Virtualization based security, including Credential Guard, currently cannot be implemented in virtual desktop implementations (VDI) due to specific supporting requirements including a TPM, UEFI with Secure Boot, and the capability to run the Hyper-V feature within the virtual desktop.

For VDIs where the virtual desktop instance is deleted or refreshed upon logoff, this is NA.

Run ""PowerShell"" with elevated privileges (run as administrator).

Enter the following:

""Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard""

If ""RequiredSecurityProperties"" does not include a value of ""2"" indicating ""Secure Boot"" (e.g., ""{1, 2}""), this is a finding.

If ""Secure Boot and DMA Protection"" is configured, ""3"" will also be displayed in the results (e.g., ""{1, 2, 3}"").

If ""VirtualizationBasedSecurityStatus"" is not a value of ""2"" indicating ""Running"", this is a finding.

Alternately:

Run ""System Information"".

Under ""System Summary"", verify the following:

If ""Device Guard Virtualization based security"" does not display ""Running"", this is finding.

If ""Device Guard Required Security Properties"" does not display ""Base Virtualization Support, Secure Boot"", this is finding.

If ""Secure Boot and DMA Protection"" is configured, ""DMA Protection"" will also be displayed (e.g., ""Base Virtualization Support, Secure Boot, DMA Protection"").

The policy settings referenced in the Fix section will configure the following registry values. However due to hardware requirements, the registry values alone do not ensure proper function.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\

Value Name: EnableVirtualizationBasedSecurity
Value Type: REG_DWORD
Value: 1

Value Name: RequirePlatformSecurityFeatures
Value Type: REG_DWORD
Value: 1 (Secure Boot only) or 3 (Secure Boot and DMA Protection)

A Microsoft article on Credential Guard system requirement can be found at the following link:

https://technet.microsoft.com/en-us/itpro/windows/keep-secure/credential-guard-requirements

NOTE:  The severity level for the requirement will be upgraded to CAT II starting January 2020."

#>