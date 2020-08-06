Param($computer)

#region:    Config

    $Vul_ID         = "63371"
    $TestName       = "Local accounts: Password Expiration"
    $CheckValue     = !$null
    $passFail       = ""
    $failures       = @()

#endregion: Config

#region:    Scan

    try{
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
            $results        = @()
            $LocalUser = Get-LocalUser | Select-Object -Property *
            foreach ($user in $LocalUser){
                $userName        = $user.Name
                $enabled         = $user.Enabled
                $PasswordExpires = $user.PasswordExpires
                $obj = [pscustomobject]@{
                    userName        = $userName
                    enabled         = $enabled
                    PasswordExpires = $PasswordExpires
                }
                $results += $obj
            }
            $results 
        } -ErrorAction Stop  
    }catch{
        $results = "Error"
    }

#endregion: Scan

#region:    Test Results

    foreach($result in $results){
        if ($result -like "*error*") {
            $passFail = "Error"
        }elseif ($result.enabled -eq "True" -and $result.PasswordExpires -eq $null) {
            $passFail = "Fail"
            $failures += $result
        } elseif ($result.enabled -eq "False") {
            $passFail = "Pass"
        } elseif ($result.enabled -eq "True" -and $result.PasswordExpires -ne $null) {
            $passFail = "Pass"
        }
    }

    if($failures){
        $results = $failures
        $passFail = "Fail"
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
