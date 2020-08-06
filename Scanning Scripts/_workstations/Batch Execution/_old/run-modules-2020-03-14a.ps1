""
""
""
""
""
""
#region:    Config
    
    ## Use Manual list:
    notepad $scriptRootPath\list.txt
    pause
    $list           = gc  $scriptRootPath\list.txt

    ## Use site wide list:
    #$list           = (Get-ADComputer -searchbase 'OU=BDSC,OU=-Iraq,DC=swa,DC=ds,DC=army,DC=mil' -Filter *).name

    #Init vars:
    $scriptRootPath = $PSScriptRoot
    $modules        = gci $scriptRootPath\modules\*.ps1
    $summaryResults        = @()
    $Offline        = @()
    $datestamp      = Get-Date -Format "yyyy-MM-dd"

#endregion: Config


#region:    Run mods

    foreach ($computer in $list){
        $compObj = [PSCustomObject]@{
            "Computer         " = $computer
        }

        $tnc = tnc $computer -InformationLevel Quiet -WarningAction SilentlyContinue

        if($tnc){
            #write-host "scanning " $computer -ForegroundColor Green
            $status = "Online"
            $compObj | Add-Member -Name "Status" -MemberType NoteProperty $status
        
            foreach ($module in $modules){
                write-host "running module " $module.BaseName -ForegroundColor Yellow
            
                $test = & $module -computer $computer
                $vulidHeadder = "V-"+$test.Vul_ID
                $compObj | Add-Member -Name $vulidHeadder -MemberType NoteProperty $test.'Pass/Fail'
            }
            $compObj
            $summaryResults += $compObj

        }else{
            write-host $computer " is offline"-ForegroundColor red
            $status = "Offline"
            $compObj | Add-Member -Name "Status" -MemberType NoteProperty $status
            $Offline += $compObj
        }
    }

#endregion: Run mods

#region:    Summary

    "Offline systems: "
    "-----------------"
    $Offline        | ft

    "Summary Results: "
    "-----------------"
    $summaryResults | ft
    
    explorer $PSScriptRoot

    $summaryResults | Export-Csv -Path $PSScriptRoot\"Summary - "$datestamp".csv" -Force -NoTypeInformation
    
    & $PSScriptRoot\"Summary - "$datestamp".csv"

#endregion: Summary


#get buffer size
#$host.UI.RawUI.BufferSize

#set buffer size width, buffer
#$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(160,5000)