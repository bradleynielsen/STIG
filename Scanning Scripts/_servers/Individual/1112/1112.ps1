$list = @("BDSCA5SWAN001","BDSCNMSWAN001","BDSCNPSWAN001","BDSCNPSWAN002","BDSCPSSWAN001")


function stigchek {
    foreach($computer in $list){
        Write-Host "Getting results for: $computer" -ForegroundColor Green

        $sessionresults = Invoke-Command -ComputerName $computer -ScriptBlock {
            ([ADSI]('WinNT://{0}' -f $env:COMPUTERNAME)).Children | Where { $_.SchemaClassName -eq 'user' } | ForEach {
                $user      = ([ADSI]$_.Path)
                $username  = ([ADSI]$_.Path).name
                $lastLogin = $user.Properties.LastLogin.Value
                $enabled   = ($user.Properties.UserFlags.Value -band 0x2) -ne 0x2
                if ($lastLogin -eq $null) {
                    $lastLogin = 'Never'
                }

                "$username, $lastLogin, $enabled "
            }
        }

        "Results for: $computer" 
        "================================================" 
        "username, lastLogin, enabled "
        $sessionresults
        "================================================" 
    }
}
$results = stigchek($list)
$results 
$results | clip 
