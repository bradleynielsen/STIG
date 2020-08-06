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
#              f) More Csv g) fixing tnc order, moving it outside the jobs h) fixed tnc progressbar i) added get all hosts function 
#              j) Added switch for manual/site selection
# 2020.03.15 - a)  Backup
# 2020.03.16 - a) Added timer b) added transcript c) added job starting message; added testing tnc bypass
# 2020.03.21 - a) Added conditional display fails
# 2020.03.21 - a) fixing fail msg b) speeding up tnc with ping /n 1 /w 1  c) fixing test variable
# 
# ##########################################################################################################################>

#region:    Config
    
        # Use 'Manual' for a manual list
        # Use 'Site'   for site wide testing list
        # Use 'test'   to skip list
        $listType = 'Manual'

#endregion: Config

#region:    Init

    $scriptRootPath     = $PSScriptRoot
    $modules            = gci $scriptRootPath\modules\*.ps1
    $datestamp          = (Get-Date -DisplayHint Time).ToString().Replace("/","-").Replace(":","").Replace(" AM","").Replace(" PM","").Replace(" ","_")
    $csvPath            = $scriptRootPath+'\Summary - '+$datestamp+'.csv'
    $summaryResults     = @()
    $testingJobs        = @()
    $ProgressPreference = 'SilentlyContinue'
    $stopwatch          =  [system.diagnostics.stopwatch]::StartNew()                            # Timer
    Start-Transcript    -OutputDirectory $PSScriptRoot\log -NoClobber -IncludeInvocationHeader      # Log
        
#endregion: Init

#region:    Functions

    Function get-OnlineHosts{
        $adComputers = (Get-ADComputer -searchbase 'OU=BDSC,OU=-Iraq,DC=swa,DC=ds,DC=army,DC=mil' -Filter *).name
        $listExport = @()

        foreach($computer in $adComputers){
            write-host "Checking network connections:" $computer -nonewline
            
            #$tnc = Test-NetConnection -ComputerName $computer -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
            #if($tnc){
            $ping = ping $computer /n 1 /w 2
            if($?){
                write-host -ForegroundColor Green " [Online]"
                $listExport += $computer
            }else{
                write-host -ForegroundColor red " [Offline]"
            
            }
        }
        $listExport
    }

    Function get-ManualHosts {
        notepad $scriptRootPath\list.txt
        pause
        gc  $scriptRootPath\list.txt
    }

#endregion: Functions

#region:    Run modules

   switch ($listType) {
        'Manual' {$list = get-ManualHosts}
        'Site'   {$list = get-OnlineHosts}
        'test'   {"Skipping List"}
        Default  {$list = get-ManualHosts}
    }

    $headline = "Running test modules for Vul IDs:
                `n"`
                + $modules.basename

    foreach ($computer in $list){
        $ping = ping $computer /n 1 /w 1
        if($?){
            "Starting job on " + $computer
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

        #Show timer
        Write-Host                        "=========================="   
        Write-Host -ForegroundColor Green "Elapsed time (HH:MM:SS):"
        $ts = [timespan]::FromMilliseconds($stopwatch.ElapsedMilliseconds)
        $ts.ToString("hh\:mm\:ss")
        Write-Host                        "==========================" 
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

    if ($failedtests) {
        $failedtests | ft
        "==================================="
        "           Failed Tests"
        "==================================="
        ''
        "Vul IDs"
        "-----------------"
        $failedtests.'Vul ID '|sort|Get-Unique
    } else {
        "==================================="
        "           Tests Results"
        "==================================="
     Write-Host -ForegroundColor Green "All tests passed!"
    }
    
    $ProgressPreference = 'Continue'
    
#endregion: Summary

#Show timer
Write-Host ''
Write-Host ''
Write-Host                        "=========================="   
Write-Host -ForegroundColor Green "Elapsed time (HH:MM:SS):"
$ts = [timespan]::FromMilliseconds($stopwatch.ElapsedMilliseconds)
$ts.ToString("hh\:mm\:ss")
Write-Host                        "==========================" 

