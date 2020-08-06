Start-Transcript -Path $PSScriptRoot\trans -Force

                    <#
Applies to:
Test	Name
    1	V-77189
    1	V-77191
    1	V-77217
    2	V-77195
    3	V-77201
    3	V-77221
    3	V-77227
    3	V-77231
    3	V-77233
    3	V-77243
    3	V-77247
    3	V-77249
    3	V-77255
    3	V-77259
    3	V-77263
    4	V-77205
    5	V-77209
    6	V-77213
    7	V-77223
    7	V-77223
    7	V-77223
    7	V-77239
    7	V-77245
    7	V-77269
    8	V-77235
    9	V-77267

                    #>


#region: Config

    notepad $PSScriptRoot\list.txt
    pause
    $list = gc $PSScriptRoot\list.txt
    #$list = (Get-ADComputer -searchbase 'OU=BDSC,OU=-Iraq,DC=swa,DC=ds,DC=army,DC=mil' -Filter *).name

#endregion: Config

#region: init

    $csv     = Import-Csv -path $PSScriptRoot\import.csv -Header 'Vul_ID', 'appName', 'GoValuesArray'
    $results = @()

#endregion: init

function test{
    param($csv)

    $Vul_ID =""
    $appName =""
    $GoValuesArray =""


}








foreach($computer in $list){
    
    $tnc = tnc $computer -InformationLevel Quiet -WarningAction SilentlyContinue

    if($tnc){
        $status = "Online"
        Write-Host "Getting results for $computer" -ForegroundColor Yellow -NoNewline
        
        $scanResults = Invoke-Command -ComputerName $computer -ScriptBlock {
            try{
                $res = (Get-ProcessMitigation -System -WarningAction SilentlyContinue)


                    $DepEnable            = $res.Dep.Enable                  #V-77091
                    $AslrBottomUp         = $res.Aslr.BottomUp               #V-77095
                    $CfgEnable            = $res.Cfg.Enable                  #V-77097
                    $SEHOPEnable          = $res.SEHOP.Enable                #V-77101
                    $HeapTerminateOnError = $res.Heap.TerminateOnError       #V-77103
                                        
                    #check go/nogo status:
                    If (($DepEnable -eq "ON") -or ($DepEnable -eq "NOTSET")) {
                        $passFail = "Pass"
                    } else{
                        $passFail = "Fail"
                    }
                    If (($AslrBottomUp -eq "ON") -or ($AslrBottomUp -eq "NOTSET")) {
                        $passFail = "Pass"
                    } else{
                        $passFail = "Fail"
                    }
                    If (($CfgEnable -eq "ON") -or ($CfgEnable -eq "NOTSET")) {
                        $passFail = "Pass"
                    } else{
                        $passFail = "Fail"
                    }
                    If (($SEHOPEnable -eq "ON") -or ($SEHOPEnable -eq "NOTSET")) {
                        $passFail = "Pass"
                    } else{
                        $passFail = "Fail"
                    }    
                    If (($HeapTerminateOnError -eq "ON") -or ($HeapTerminateOnError -eq "NOTSET")) {
                        $passFail = "Pass"
                    } else{
                        $passFail = "Fail"
                    }
                    
                    if($passFail -eq "Fail"){
                        Write-Host " Fail" -ForegroundColor Red
                    }elseif($passFail -eq "Pass"){
                        Write-Host " Pass" -ForegroundColor Green
                    } 


                $invkCmdObj = [PSCustomObject]@{
                    "DepEnable"            = $DepEnable                  #V-77091
                    "AslrBottomUp"         = $AslrBottomUp               #V-77095
                    "CfgEnable"            = $CfgEnable                  #V-77097
                    "SEHOPEnable"          = $SEHOPEnable                #V-77101
                    "HeapTerminateOnError" = $HeapTerminateOnError       #V-77103
                    "passFail"               = $passFail
                }

            }catch{
                 Write-Host "WinRM Failure" -ForegroundColor Red
                 "WinRM Failure"
            }
            $invkCmdObj 
            #end Invoke-Command
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
        "Pass/Fail       "              = $scanResults.passFail
    }
    $results += $obj
    #clv scanResults,obj,status,tnc
} 

$results | sort 'Scan Results' | ft
$results | sort 'Scan Results' | clip
$results | sort 'Scan Results' | Export-Csv -Path $PSScriptRoot\results.csv




