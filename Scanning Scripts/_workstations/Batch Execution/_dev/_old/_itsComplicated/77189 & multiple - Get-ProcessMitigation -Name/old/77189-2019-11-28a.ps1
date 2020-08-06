
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

    $csv     = Import-Csv -path $PSScriptRoot\import.csv 
    $results = @()

#endregion: init

function test{
    param($value,$obj)
        
        $v0  = $value.Split(".")[0]
        $v1  = $value.Split(".")[1]
        $testRes = (Get-ProcessMitigation -Name $line.Name -WarningAction SilentlyContinue).$v0.$v1
        
        write-host $v0" - " -NoNewline
        write-host $v1":"   -NoNewline
        
        if ($testRes -eq "NOTSET"){
            write-host $testRes -NoNewline
            write-host " Fail!" -ForegroundColor red
            $valueTest = "FAIL"
        }elseif ($testRes -eq "ON"){
            write-host $testRes -NoNewline
            write-host " Pass" -ForegroundColor green
            $valueTest = "PASS"
            
        }

        $obj."Class"       = $v0
        $obj."Property"    = $v1
        $obj."Value"       = $testRes
        $obj."Test_Status" = $valueTest
        
        #clv v0,v1,testRes,valueTest
        $obj
}



foreach ($line in $csv){
    Write-Host -ForegroundColor Yellow $line.Vul_ID -NoNewline
    Write-Host -ForegroundColor Yellow ": "$line.appName -NoNewline
    
    $GoValuesArray = @($line.GoValuesArray.Split(";"))
    Write-Host -ForegroundColor Green ":"$GoValuesArray.count"vlaues"

    $obj = [PSCustomObject]@{
        "Computer"    = $computer
        "Status"      = $status                          
        "Vul_ID"      = $line.Vul_ID
        "Application" = $line.Name
        "Class"       = ""
        "Property"    = ""
        "Value"       = ""
        "Test_Status" = ""
    }
    

    foreach ($value in $GoValuesArray){
        $test = test -value $value -obj $obj
        $results += $test

    }


}




$results | sort Vul_ID  | ft 
$results | sort Vul_ID  | ft | clip 
$results | sort Vul_ID  | ft | Export-Csv -Path $PSScriptRoot\results.csv 


