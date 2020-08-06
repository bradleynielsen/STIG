Param($computer)

#region:    Config

    $Vul_ID         = "63367"
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
"If a hosted hypervisor (Hyper-V, VMware Workstation, etc.) is installed on the system, verify only authorized user accounts are allowed to run virtual machines.

For Hyper-V, Run ""Computer Management"".
Navigate to System Tools >> Local Users and Groups >> Groups.
Double click on ""Hyper-V Administrators"".

If any unauthorized groups or user accounts are listed in ""Members:"", this is a finding.

For hosted hypervisors other than Hyper-V, verify only authorized user accounts have access to run the virtual machines. Restrictions may be enforced by access to the physical system, software restriction policies, or access restrictions built in to the application.

If any unauthorized groups or user accounts have access to create or run virtual machines, this is a finding.

All users authorized to create or run virtual machines must be documented with the ISSM/ISSO. Accounts nested within group accounts must be documented as individual accounts and not the group accounts."




#>
