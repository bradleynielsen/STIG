Param($computer)

#$computer = "BDSCWKN1FLE7C22"

#region:    Config

    $Vul_ID     = "63337"
    $TestName   = "BitLocker enabled"
    $CheckValue = "FullyEncrypted"
    $passFail   = ""

#endregion: Config

try{
    $results = Invoke-Command -ComputerName $computer -ScriptBlock {
        return (Get-BitLockerVolume).VolumeStatus
    } -ErrorAction stop
}catch{
    $results = "Error"
}

foreach($value in $results ){

    if($results -eq $CheckValue){
        $passFail = "Pass"
    }else{
        $passFail = "Fail"
        break
    }
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
Rule Title: Windows 10 information systems must use BitLocker to encrypt all disks to protect the confidentiality and integrity of all information at rest.

Discussion: If data at rest is unencrypted, it is vulnerable to disclosure. Even if the operating system enforces permissions on data access, an adversary can remove non-volatile memory and read it directly, thereby circumventing operating system controls. Encrypting the data ensures that confidentiality is protected even when the operating system is not running.

Check Text: Verify all Windows 10 information systems (including SIPRNET) employ BitLocker for full disk encryption.

If full disk encryption using BitLocker is not implemented, this is a finding.

Verify BitLocker is turned on for the operating system drive and any fixed data drives.

Open "BitLocker Drive Encryption" from the Control Panel.

If the operating system drive or any fixed data drives have "Turn on BitLocker", this is a finding.

NOTE: An alternate encryption application may be used in lieu of BitLocker providing it is configured for full disk encryption and satisfies the pre-boot authentication requirements (WN10-00-000031 and WN10-00-000032).

Fix Text: Enable full disk encryption on all information systems (including SIPRNET) using BitLocker.

BitLocker, included in Windows, can be enabled in the Control Panel under "BitLocker Drive Encryption" as well as other management tools.

NOTE: An alternate encryption application may be used in lieu of BitLocker providing it is configured for full disk encryption and satisfies the pre-boot authentication requirements (WN10-00-000031 and WN10-00-000032).

References


#>