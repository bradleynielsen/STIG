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
# 2020.03.14 - a) auto open csv results b) add note for buffer size  c) added init region d) adding asjob e) fixing csv 
#              f) More Csv g) fixing tnc order, moving it outside the jobs h) fixed tnc progressbar
#
# ##########################################################################################################################>

#region:    Init

    $scriptRootPath     = $PSScriptRoot
    $modules            = gci $scriptRootPath\modules\*.ps1
    $datestamp          = (Get-Date -DisplayHint Time).ToString().Replace("/","-").Replace(":","").Replace(" AM","").Replace(" PM","").Replace(" ","_")
    $csvPath            = $scriptRootPath+'\Summary - '+$datestamp+'.csv'
    $summaryResults     = @()
    $testingJobs        = @()
    $ProgressPreference = 'SilentlyContinue'

    
#endregion:

#region:    Config
    
    ## Use Manual list:
    notepad $scriptRootPath\list.txt
    pause
    $list = gc  $scriptRootPath\list.txt

    ## Use this for site wide testing
    #$list = (Get-ADComputer -searchbase 'OU=BDSC,OU=-Iraq,DC=swa,DC=ds,DC=army,DC=mil' -Filter *).name           

#endregion: Config

#region:    Run modules
        $headline = "Running test modules for Vul IDs:
        `n"`
         + $modules.basename


    foreach ($computer in $list){
        $tnc = tnc $computer -InformationLevel Quiet -WarningAction SilentlyContinue
        if($tnc) {
            $testingJobs += Start-Job -Name $computer {
                $computer = $args[0]        
                $modules  = $args[1]        
            
                $compObj = [PSCustomObject]@{ 
                    "Computer         " = $computer  # init the resuts table
                }
                $status = "Online" # set status
                $compObj | Add-Member -Name "Status" -MemberType NoteProperty $status
                foreach ($module in $modules){
                    $test = & $module -computer $computer # run the test
                    $vulidHeadder = "V-"+$test.Vul_ID
                    $compObj | Add-Member -Name $vulidHeadder -MemberType NoteProperty $test.'Pass/Fail'
                }
                $compObj # return object
            } -ArgumentList $computer, $modules
            
        } else{
            #set all values to "offline"
            $compObj = [PSCustomObject]@{ 
                "Computer         " = $computer  # init the resuts table
            }
            $status = "Offline" # set status
            $compObj | Add-Member -Name "Status" -MemberType NoteProperty $status # add status

            foreach ($module in $modules){
                $vulidHeadder = "V-"+$test.Vul_ID
                $compObj | Add-Member -Name $vulidHeadder -MemberType NoteProperty $status # add status
            }
            $compObj # return object
        }
    }

#endregion: Run modules

#region:    Process Jobs

    while (($testingJobs|Get-Job).State -eq "running"){
        $status = @()
        foreach ($job in $testingJobs){
            $obj = [pscustomobject]@{
                "Computer Name  " = $job.name
                "Scan State"      = $job.State
            }
            $status += $obj 
        }
        ""
        ""
        $headline
        ""
        ""
        "Active Jobs:"
        $status|where-Object{$_.'Scan State' -eq 'Running'} | ft
        sleep 4
        cls
    }

    $testingJobs | Wait-Job
    $summaryResults += $testingJobs | Receive-Job -Keep
    #$testingJobs| remove-Job

#endregion: Process Jobs

#region:    Summary

    explorer $scriptRootPath
    $summaryResults | Export-Csv -Path $csvPath -Force -NoTypeInformation 
    & $csvPath
    "==================================="
    "           Failed Tests"
    "==================================="
    $failedtests = @()

    foreach ($computerResult in $summaryResults ){
        $computerResult.PSObject.Properties | ForEach-Object {
            if($_.Value -match "Fail"){
                $failure = [pscustomobject]@{
                    "Computer Name  " = $computerResult.'Computer         '
                    "Vul ID " = $_.Name
                }
                $failedtests += $failure           
            } 
        }       
    }

    $failedtests | ft
    "Vul IDs"
    "-----------------"
    $failedtests.'Vul ID ' | Get-Unique
    
    $ProgressPreference = 'Continue'
    
#endregion: Summary
