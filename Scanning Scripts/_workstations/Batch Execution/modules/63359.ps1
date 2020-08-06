Param($computer)

#region:    Config

    $Vul_ID         = "63359"
    $TestName       = "Inactive accounts"
    $CheckValue     = "True"
    $passFail       = ""
    $failures       = @()
    $exemptAccounts = @(
                            "DOD_Admin"         ,     
                            "DefaultAccount"    ,         
                            "SWA_AD"            ,            
                            "SWA_Admin"         ,         
                            "Visitor"           ,           
                            "WDAGUtilityAccount"
                        )

#endregion: Config

#region:    Scan

    try{
    
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
            $results     = @()
            $LocalAdmins = (Get-LocalGroupMember -Group Administrators).name.replace($env:COMPUTERNAME+"\", "")
            $exemptAccounts = $args

            ([ADSI]('WinNT://{0}' -f $env:COMPUTERNAME)).Children | Where { $_.SchemaClassName -eq 'user' } | ForEach {

                $user      = ([ADSI]$_.Path)
                $userName  = $user.name[0]
                $lastLogin = $user.Properties.LastLogin.Value
                $enabled   = ($user.Properties.UserFlags.Value -band 0x2) -ne 0x2

                if ($lastLogin -eq $null) {
                    $lastLogin = 'Never'
                }

                $isAdmin  = $LocalAdmins.Contains($userName)
                $isExempt = $exemptAccounts.Contains($userName)
                $results += [pscustomobject]@{
                    userName  = $userName
                    lastLogin = $lastLogin
                    enabled   = $enabled
                    isAdmin   = $isAdmin
                    isExempt  = $isExempt
                }

            }
            $results 
        } -ErrorAction Stop -ArgumentList $exemptAccounts
    }catch{
        $results = "Error"
    }

#endregion: Scan



#region:    Test Results


    foreach($result in $results){
        if ($result -like "*error*") {
            $passFail = "Error"
        }elseif ($result.isAdmin -eq "True" -or $result.isExempt -eq "True") {
            $passFail = "Pass"
        } elseif ($result.lastLogin -ne "Never" -and $result.isExempt -ne "True" -and $result.isAdmin -ne "True" ) {
            $passFail = "Fail"
            $failures += $result

        }
    }

    
    if($failures){
        $results = $failures
    }


#endregion: Test Results

$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue
    "Value"      = $results.userName -join ', '
    "Pass/Fail"  = $passFail
}




$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj

return $resultsObj

<#

Check Content
"Run ""PowerShell"".
Copy the lines below to the PowerShell window and enter.

""([ADSI]('WinNT://{0}' -f $env:COMPUTERNAME)).Children | Where { $_.SchemaClassName -eq 'user' } | ForEach {
   $user = ([ADSI]$_.Path)
   $lastLogin = $user.Properties.LastLogin.Value
   $enabled = ($user.Properties.UserFlags.Value -band 0x2) -ne 0x2
   if ($lastLogin -eq $null) {
      $lastLogin = 'Never'
   }
   Write-Host $user.Name $lastLogin $enabled 
}""

This will return a list of local accounts with the account name, last logon, and if the account is enabled (True/False).
For example: User1  10/31/2015  5:49:56  AM  True

Review the list to determine the finding validity for each account reported.

Exclude the following accounts:
Built-in administrator account (Disabled, SID ending in 500)
Built-in guest account (Disabled, SID ending in 501)
Built-in DefaultAccount (Disabled, SID ending in 503)
Local administrator account

If any enabled accounts have not been logged on to within the past 35 days, this is a finding.

Inactive accounts that have been reviewed and deemed to be required must be documented with the ISSO."




#>
