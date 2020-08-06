## Applies to:
    #V-77091
    #V-77095
    #V-77097
    #V-77101
    #V-77103

Start-Transcript -Path $PSScriptRoot -Force


notepad $PSScriptRoot\list.txt
pause
$list = gc $PSScriptRoot\list.txt

#$list = (Get-ADComputer -searchbase 'OU=BDSC,OU=-Iraq,DC=swa,DC=ds,DC=army,DC=mil' -Filter *).name
$results = @()

#clv scanResults,obj,status,tnc -ErrorAction SilentlyContinue


foreach($computer in $list){
    
    $tnc = tnc $computer -InformationLevel Quiet -WarningAction SilentlyContinue

    if($tnc){
        $status = "Online"
        Write-Host "Getting results for $computer" -ForegroundColor Green
        
        $scanResults = Invoke-Command -ComputerName $computer -ScriptBlock {
            try{
                $res = (Get-ProcessMitigation -System -WarningAction SilentlyContinue)
                $DepEnable            = $res.Dep.Enable                  #V-77091
                $AslrBottomUp         = $res.Aslr.BottomUp               #V-77095
                $CfgEnable            = $res.Cfg.Enable                  #V-77097
                $SEHOPEnable          = $res.SEHOP.Enable                #V-77101
                $HeapTerminateOnError = $res.Heap.TerminateOnError       #V-77103
                $obj = [PSCustomObject]@{
                    "DepEnable"            = $DepEnable
                    "AslrBottomUp"         = $AslrBottomUp
                    "AslrCfg"              = $CfgEnable
                    "SEHOPEnable"          = $SEHOPEnable
                    "HeapTerminateOnError" = $HeapTerminateOnError
                }
            }catch{
                 Write-Host "WinRM Failure" -ForegroundColor Red
                 "WinRM Failure"
            }
        } 
    }else{
        $status = "Offline"
    }
    $obj = [PSCustomObject]@{
        "Computer       "       = $computer
        "Status  "              = $status
        "DepEnable "            = $scanResults.DepEnable
        "AslrBottomUp "         = $scanResults.AslrBottomUp
        "CfgEnable "            = $scanResults.CfgEnable
        "SEHOPEnable "          = $scanResults.SEHOPEnable
        "HeapTerminateOnError " = $scanResults.HeapTerminateOnError
    }
    $results += $obj
    #clv scanResults,obj,status,tnc
} 

$results | sort 'Scan Results' | ft
$results | sort 'Scan Results' | clip
$results | sort 'Scan Results' | Export-Csv -Path $PSScriptRoot\results.csv

 