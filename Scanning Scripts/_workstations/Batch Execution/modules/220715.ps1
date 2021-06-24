Param($computer)

#region:    Config
    $STIG_Version   = 'Windows 10 Security Technical Implementation Guide :: Version 2, Release: 2 Benchmark Date: 04 May 2021'
    $Vul_ID         = "220715"
    $TestName       = "Local accounts"
    $CheckValue     = "True"
    $passFail       = ""
    $failures       = @()
    $exemptAccounts = @(
                            "Administrator"      ,     
                            "Guest"              ,     
                            "DefaultAccount"     ,     
                            "defaultuser0"       ,     
                            "WDAGUtilityAccount" ,     
                            "DOD_Admin"          ,     
                            "SWA_AD"             ,            
                            "SWA_Admin"                  
                        )

#endregion: Config

#region:    Scan

    try{
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
            $results        = @()
            $LocalAdmins    = (Get-LocalGroupMember -Group Administrators).name.replace($env:COMPUTERNAME+"\", "")
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
"Run ""Computer Management"".
Navigate to System Tools >> Local Users and Groups >> Users.

If local users other than the accounts listed below exist on a workstation in a domain, this is a finding.

Built-in Administrator account (Disabled)
Built-in Guest account (Disabled)
Built-in DefaultAccount (Disabled)
Built-in defaultuser0 (Disabled)
Built-in WDAGUtilityAccount (Disabled)
Local administrator account(s)

All of the built-in accounts may not exist on a system, depending on the Windows 10 version."


#>
