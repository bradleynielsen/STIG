
$list = @("BDSCWCDYAAA0N01","BDSCA5SWAN001","BDSCNMSWAN001","BDSCNPSWAN001","BDSCNPSWAN002","BDSCPSSWAN001")


function stigchek {
    foreach($computer in $list){
        Write-Host "Getting results for: $computer" -ForegroundColor Green

        $sessionresults = Invoke-Command -ComputerName $computer -ScriptBlock {
            Get-ChildItem -Path Cert:Localmachine\disallowed | 
            Where {$_.Issuer -Like "*DoD Interoperability*" -and $_.Subject -Like "*DoD*"} | 
            FL Subject, Issuer, Thumbprint, NotAfter

        }

        "Results for: $computer" 
        "================================================" 
        $sessionresults
        "================================================" 

    }

}


$results = stigchek($list)

$results 
$results | clip 



ls"%SystemRoot%\ System32\winevt\Logs" 