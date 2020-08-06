Param($computer)
#$computer = 'BDSCWKNAEAGCBAB'

#region:    Config

    $Vul_ID     = "63599"
    $TestName   = "Device Guard - hypervisor support"
    $CheckValue = 1
    $passFail   = ""

#endregion: Config
    
try{
    $results = Invoke-Command -ComputerName $computer -ScriptBlock {
        Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard| select SecurityServicesRunning 
    } -ErrorAction stop

}catch{
    $results  = "Error"
    $passFail = "Error"
}

if($results -ne "Error"){
    if(($results.SecurityServicesRunning|Out-String).Contains($CheckValue)){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
    }
}

$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue
    "Value"      = $results.SecurityServicesRunning -join ","
    "Pass/Fail"  = $passFail
}

$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj

return $resultsObj

<#
Check Content

"Confirm Credential Guard is running on domain-joined systems.

For those devices that support Credential Guard, this feature must be enabled. Organizations need to take the appropriate action to acquire and implement compatible hardware with Credential Guard enabled.

Virtualization based security, including Credential Guard, currently cannot be implemented in virtual desktop implementations (VDI) due to specific supporting requirements including a TPM, UEFI with Secure Boot, and the capability to run the Hyper-V feature within the virtual desktop.

For VDIs where the virtual desktop instance is deleted or refreshed upon logoff, this is NA.

Run ""PowerShell"" with elevated privileges (run as administrator).
Enter the following:
""Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard""

If ""SecurityServicesRunning"" does not include a value of ""1"" (e.g., ""{1, 2}""), this is a finding.

Alternately:

Run ""System Information"".
Under ""System Summary"", verify the following:
If ""Device Guard Security Services Running"" does not list ""Credential Guard"", this is finding.

The policy settings referenced in the Fix section will configure the following registry value. However, due to hardware requirements, the registry value alone does not ensure proper function.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\

Value Name: LsaCfgFlags
Value Type: REG_DWORD
Value: 0x00000001 (1) (Enabled with UEFI lock)




Win32_DeviceGuard 
AvailableSecurityProperties
This field helps to enumerate and report state on the relevant security properties for Windows Defender Device Guard.

TABLE 1
Value	Description
0.	If present, no relevant properties exist on the device.
1.	If present, hypervisor support is available.
2.	If present, Secure Boot is available.
3.	If present, DMA protection is available.
4.	If present, Secure Memory Overwrite is available.
5.	If present, NX protections are available.
6.	If present, SMM mitigations are available.
7.	If present, Mode Based Execution Control is available.


"

#>


