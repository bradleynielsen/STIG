Param($computer)

#region:    Config
    $STIG_Version = 'Windows 10 Security Technical Implementation Guide :: Version 2, Release: 2 Benchmark Date: 04 May 2021'
    $Vul_ID       = "220716"
    $TestName     = "Local accounts: Password Expiration"
    $CheckValue   = !$null
    $passFail     = ""
    $failures     = @()

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
"Run ""Computer Management"".
Navigate to System Tools >> Local Users and Groups >> Users.
Double click each active account.

If ""Password never expires"" is selected for any account, this is a finding."


#>
