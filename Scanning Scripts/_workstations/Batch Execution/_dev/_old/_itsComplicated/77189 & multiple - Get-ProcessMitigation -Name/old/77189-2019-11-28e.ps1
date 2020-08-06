$PSScriptRoot
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

    #notepad $PSScriptRoot\list.txt
    #pause
    $list = gc $PSScriptRoot\list.txt
    #$list = (Get-ADComputer -searchbase 'OU=BDSC,OU=-Iraq,DC=swa,DC=ds,DC=army,DC=mil' -Filter *).name

#endregion: Config

#region: init
    $scriptPath = $PSScriptRoot
    $csv     = Import-Csv -path $scriptPath\import.csv 
    $results = @()
    $Vul_ID_Test_Results = @()
    $PassSummary = @()

#endregion: init

foreach ($line in $csv){
    Write-Host -ForegroundColor Yellow $line.Vul_ID -NoNewline
    Write-Host -ForegroundColor Yellow ": "$line.appName -NoNewline
    
    $GoValuesArray = @($line.GoValuesArray.Split(";"))
    Write-Host -ForegroundColor Green ":"$GoValuesArray.count"vlaues"

    foreach ($value in $GoValuesArray){
        $appName  = $line.Name
        $class    = $value.Split(".")[0]
        $property = $value.Split(".")[1]
        $propVal  = (Get-ProcessMitigation -Name $appName -WarningAction SilentlyContinue).$class.$property
        
        write-host $class" - "  -NoNewline
        write-host $property":" -NoNewline
        
        if ($propVal -eq "NOTSET"){
            write-host $testRes -NoNewline
            write-host " Fail!" -ForegroundColor red
            $valTest_Status = "FAIL"
        }elseif ($propVal -eq "ON"){
            write-host $testRes -NoNewline
            write-host " Pass"  -ForegroundColor green
            $valTest_Status = "PASS"
            
        }

        $obj = [PSCustomObject][ordered]@{
            "Computer"      = $computer
            "Status"        = $status                          
            "Vul_ID"        = $line.Vul_ID
            "Application"   = $line.Name
            "Class"         = $class
            "Property"      = $property
            "Value"         = $propVal
            "Prop_Val_Test" = $valTest_Status
        }

        #clv v0,v1,testRes,valueTest
        $results += $obj
    }
}








foreach ($line in $csv){
    $Vul_ID = $line.Vul_ID
    $pvtres = ($results | ? -Property Vul_ID  -EQ $Vul_ID).Prop_Val_Test

    if("FAIL" -in $pvtres){
        $passFail = "FAIL"
    }elseif ("PASS" -in $pvtres){
        $passFail = "PASS"
    }

    $obj = [PSCustomObject]@{
        Computer    = $computer
        Status      = $status                          
        Vul_ID      = $line.Vul_ID 
        "Pass/Fail" = $passFail 
    }
    $Vul_ID_Test_Results += $obj

}

foreach ($line in $Vul_ID_Test_Results){
    if ($line."Pass/Fail" -eq "Pass" ){
        
        $obj = [PSCustomObject]@{
            Computer    = $line.computer
            Status      = $line.status                          
            Vul_ID      = $line.Vul_ID 
            "Pass/Fail" = $line."Pass/Fail" 
        }
        $PassSummary += $obj
    }
}




$results | sort Vul_ID  | ft 
$results | sort Vul_ID  | ft | clip 
$results | sort Vul_ID  | Export-Csv -Path $scriptPath\detailed_results.csv  -Force -NoTypeInformation

$Vul_ID_Test_Results | sort Vul_ID  | ft 
$Vul_ID_Test_Results | sort Vul_ID  | ft | clip 
$Vul_ID_Test_Results | sort Vul_ID  | Export-Csv -Path $scriptPath\summary_results.csv  -Force -NoTypeInformation

$PassSummary | sort Vul_ID  | ft 
$PassSummary | sort Vul_ID  | ft | clip 
$PassSummary | sort Vul_ID  | Export-Csv -Path $scriptPath\PassSummary.csv  -Force -NoTypeInformation

