notepad $PSScriptRoot\list.txt
pause
$list = gc $PSScriptRoot\list.txt
$results = @()

clv scanResults,obj,status,tnc -ErrorAction SilentlyContinue

foreach($computer in $list){
    
    $tnc = tnc $computer -InformationLevel Quiet -WarningAction SilentlyContinue
    if($tnc){
        $status = "Online"
        Write-Host "Getting results for $computer" -ForegroundColor Green
        $scanResults = Invoke-Command -ComputerName $computer -ScriptBlock {
            #insert query here \/
            ls -path c:\ -Recurse -Include "*.p12","*.pfx" 
        } -ErrorAction SilentlyContinue
    }else{
        $status = "Offline"
    }

    $obj = [PSCustomObject]@{
        "Computer       "   = $computer
        "Status  "          = $status
        "Scan Results     " = $scanResults
    }
    $results += $obj
    clv scanResults,obj,status,tnc
}

$results | ft
$results | ft | clip 





