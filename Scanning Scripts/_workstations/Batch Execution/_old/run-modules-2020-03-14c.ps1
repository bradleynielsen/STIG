<# ##########################################################################################################################
# NAME: Manual stig checks
# 
# AUTHOR:  Brad Nielsen
# DATE:    2019.12.23
# EMAIL:   bradley.t.nielsen.ctr@mail.mil
# 
# COMMENT: This script will run tests for manual stig checks on Vul IDs not scanned by SCAP scanning tool. 
# This is intended to be used with the vulnerability tracker. Contact Brad Nielsen for more details to 
# auto load these results into the CKL using the vulnerability tracker.
#
# VERSION HISTORY
# 2019.12.23 - Initial version
# 2020.03.13 - a) auto open csv results b) add note for buffer size  c) added init region 
#
# ##########################################################################################################################>


#region:    Config
    
    ## Use Manual list:
    notepad $scriptRootPath\list.txt
    pause
    $list = gc  $scriptRootPath\list.txt
    #$list = (Get-ADComputer -searchbase 'OU=BDSC,OU=-Iraq,DC=swa,DC=ds,DC=army,DC=mil' -Filter *).name           ## Use this for site wide testing


#endregion: Config

#region:    Init

    $scriptRootPath = $PSScriptRoot
    $modules        = gci $scriptRootPath\modules\*.ps1
    $Offline        = @()
    $datestamp      = Get-Date -Format "yyyy-MM-dd"
    $summaryResults = @()
    
#endregion: 

#region:    Run mods

    "Running test modules for Vul IDs:"
    $modules.basename
    ""
    ""

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