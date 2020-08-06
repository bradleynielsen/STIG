try{
    
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {
        
        
            $LocalAdmins = (Get-LocalGroupMember -Group Administrators).name.replace($env:COMPUTERNAME+"\", "")
            $results     = @()

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

            $results | ft

        } -ErrorAction Stop -ArgumentList $exemptAccounts
}catch{
    $results = "Error"
}