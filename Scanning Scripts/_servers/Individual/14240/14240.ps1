""
""
""
""
""
""
"V-14240"

#region: Update User Config Varibales here:

    $searchPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $RegistryHive = 'HKEY_LOCAL_MACHINE'
    $RegistryPath = '\Software\Microsoft\Windows\CurrentVersion\Policies\System\'
    $path         = $searchPrefix+$RegistryHive+$RegistryPath
    $ValueName    = 'EnableLUA'
    $ValueType    = "REG_DWORD"
    $value        = "1"

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

#$resultsArray | Export-Csv $PSScriptRoot\SCHANNEL.csv -NoTypeInformation -Force
#$res = Get-ItemProperty $path | Select-Object -Property * |? {$_.property -eq $ValueName}
 