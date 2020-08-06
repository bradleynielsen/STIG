""
""
""
""
""
""
"V-21954"

#region: Update User Config Varibales here:

    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $RegistryHive = 'HKEY_LOCAL_MACHINE'
    $RegistryPath = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\'
    $path         = $searchPrefix+$RegistryHive+$RegistryPath
    $ValueName    = 'SupportedEncryptionTypes'
    $ValueType    = "REG_DWORD"
    $value        = "2147483640"

#region: Update User Config Varibales here:


notepad $PSScriptRoot\list.txt
pause
$list = get-content $PSScriptRoot\list.txt
$resultsArray =  @()


foreach ($computer in $list){
    $tnc = tnc $computer -InformationLevel Quiet -WarningAction SilentlyContinue
    if($tnc){
        $status = "Online"
        Write-Host "Getting results for $computer" -ForegroundColor Green
        $res = Invoke-Command -ComputerName $computer -ArgumentList ($path, $ValueName) -ScriptBlock {
            param(
                $path,
                $ValueName
            )

            try{
                $res = Get-ItemProperty $path 
            }catch{
                write-host "Server "$computer": value not found ERROR" -ForegroundColor Red
                $res = $Error[($Error.Count)-1].Exception
            }
            return $res
        }
        $propVal = $res.$ValueName

        if ($propVal -eq $value ){
            $valTest_Status = "PASS"
            write-host "Server "$valTest_Status
        }elseif ($propVal -ne $value){
            $valTest_Status = "FAIL"
            write-host "Server "$valTest_Status
        }

        $obj = [PSCustomObject][ordered]@{
            "Computer"      = $computer
            "Status"        = $status                          
            "Value"         = $propVal
            "Pass/Fail"     = $valTest_Status
        }

        #clv v0,v1,testRes,valueTest
        $resultsArray += $obj
    }
}
$resultsArray 
$resultsArray > C:\resultsArray.txt  

#$resultsArray | Export-Csv $PSScriptRoot\SCHANNEL.csv -NoTypeInformation -Force
#$res = Get-ItemProperty $path | Select-Object -Property * |? {$_.property -eq $ValueName}
 <#
 "If the following registry value does not exist or is not configured as specified, this is a finding.

Registry Hive: HKEY_LOCAL_MACHINE
Registry Path: \SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\

Value Name: SupportedEncryptionTypes

Value Type: REG_DWORD
Value: 0x7ffffff8 (2147483640)

Note: Removing the previously allowed RC4_HMAC_MD5 encryption suite may have operational impacts and must be thoroughly tested for the environment before changing. This includes but is not limited to parent\child trusts where RC4 is still enabled; selecting ""The other domain supports Kerberos AES Encryption"" may be required on the domain trusts to allow client communication across the trust relationship."

 
 
 #>