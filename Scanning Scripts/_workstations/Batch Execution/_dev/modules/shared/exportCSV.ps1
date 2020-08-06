Param($resultsObj)

function Private:exportCSV {
    Param($resultsObj)

    $csvpath    = Resolve-Path $PSScriptRoot\..\..\test_results
    $Vul_ID     = $resultsObj.Vul_ID
    $datestamp  = (Get-Date -DisplayHint Time).ToString().Replace("/","-")
    $exportobject = $resultsObj 
    $exportobject | Add-Member -Name Timestamp -MemberType NoteProperty $datestamp
    
    $writestatus = $false

    while($writestatus -eq $false){
        try{
            $exportobject | Export-Csv -Path $csvpath\$Vul_ID" - results.csv" -Append -NoTypeInformation -ErrorAction Stop
            $writestatus = $true
        }catch{
            sleep 1
        }
    }
    
    

}
exportCSV -resultsObj $resultsObj


<#
    $exportobject = $resultsObj 

$resultsObj.Computer
$resultsObj.Vul_ID
$resultsObj."Test Name"
$resultsObj.CheckValue
$resultsObj.Value
$resultsObj."Pass/Fail"


"Computer"   = $computer
"Vul_ID"     = $Vul_ID
"Test Name"  = $TestName
"CheckValue" = $CheckValue -join ', '
"Value"      = $results.Value -join ', '
"Pass/Fail"  = $passFail


$resultsObj | Export-Csv -Path $PSScriptRoot\$Vul_ID" - results.csv" -Append -NoTypeInformation
return $resultsObj


#>
