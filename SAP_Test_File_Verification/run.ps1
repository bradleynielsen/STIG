<#
----------------------
How to run the script:
----------------------
1. Right click on "run.ps1"
2. Click Run with PowerShell

---------------------------
How to configure the files
---------------------------
You will need to add information from the SAP to ensure that information from the testing files agrees with the SAP 
and the lookup tables used in the script. 
Do the following:

1.  Copy test files in the respective folders

2.  Review the "config" folder:
        • assessmentmethods.csv (This is the list of Hosts and test battery from the SAP [Assessment Methods] tab)
        • saplookuptable.csv (This is used to tie the SAP Test Battery list to the files's STIG ID.)

3.  Configure the assessmentmethods.csv 

        a) Copy the SAP [Assessment Methods] columns
            • Test Target - Hostname
            • IP Address
            • Test Battery

        b) Paste this into the file called "assessmentmethods.csv"

4.  Configure the saplookuptable.csv

        a) ensure that all Test Battery lines are paired with the correct STIG IDs from CKL and XCCDF
        
        b) If the list is not complete do the following:

            i) Run this script to produce a list of unique IDs in the output folder. There will be two files:
                • UniqueSTIGIDs.txt
                • UniqueTestBatteryList.txt

            ii) Copy the UniqueSTIGIDs values from "UniqueSTIGIDs.txt" into "saplookuptable.csv" 
                 - copy UniqueSTIGIDs.txt 
                 - open saplookuptable.csv
                 - paste into  ["stigid"] column

            iii) Copy the testBattery from "UniqueTestBatteryList.txt" to the "saplookuptable.csv" "sapTestBattery" column
                 - copy UniqueTestBatteryList.txt 
                 - open saplookuptable.csv
                 - paste into  ["sapTestBattery"] column


5.  Once all of the configuration is complete you can run the script. 

6.  Open the "output" folder to view the output from the script
        a) "completenessTest.csv" 
                will give you insight on:
                • Missing files for each test battery
                • Duplicate files for each test battery
                • Inconsistent STIG IDs between the SAP <> Filename <> STIG data
                • Inconsistent STIG versions between the STIGS
                • Inconsistent STIG versions between the STIGS   

        b) "fileValues.csv" 
            Details from inside the CKL and XCCDF files

        c) UniqueSTIGIDs.txt
            Produced from the STIG files

        d) UniqueTestBatteryList.txt
            Produced from the "saplookuptable.csv"


#>

#region init

    $date                = Get-Date -Format yyyy-MM-dd
    $scriptRootPath      = $PSScriptRoot
    $fileValuesObj       = @()
    $completenessTestObj = @()
    $duplicateFiles      = @()
    $missingFiles        = @()
    $wrongSTIGtitle      = @()
    $cklFiles            = Get-ChildItem "$scriptRootPath\files\ckl"   # get list of ckl files
    $xccdfFiles          = Get-ChildItem "$scriptRootPath\files\xccdf" # get list of xccdf files
    $sapLookupTable      = Import-Csv -path "$scriptRootPath\config\saplookuptable.csv" # get the lookup table for test battery and stig id
    $assessmentmethods   = Import-Csv -path "$scriptRootPath\config\assessmentmethods.csv" # get sap assessment methods table

#endregion init

#region CKL
    Write-Host "Reading CKL files..." -NoNewline
    foreach ($cklFile in $cklFiles){        
        if([System.IO.Path]::GetExtension($cklFile) -eq ".ckl" ){ # only process ckl files

            [xml]$cklXmlDocument = get-content $cklFile.FullName # get xml data for ckl

            #region CKL information        
                $cklHOST_NAME = $cklXmlDocument.CHECKLIST.ASSET.HOST_NAME    # get CKL host information
                
                # get the CKL ID, title, version, and release
                $STIG_INFO = $cklXmlDocument.CHECKLIST.STIGS.iSTIG.STIG_INFO # STIG_INFO has an element called "title" that is the name of the STIG
                foreach ($SI_DATA in $STIG_INFO) {
                    foreach ($element in $SI_DATA.SI_DATA){

                        if($element.SID_NAME -eq "version"){
                            $versionNumber = $element.SID_DATA # Get CKL version number
                        }

                        if($element.SID_NAME -eq "stigid"){
                            $stigid   = $element.SID_DATA      # Get STIG ID
                        }

                        if($element.SID_NAME -eq "title"){    
                            $stigTitle = $element.SID_DATA     # Get STIG title
                        }

                        if($element.SID_NAME -eq "releaseinfo"){
                            $releaseinfo = $element.SID_DATA
                            #parse out release number
                            $startingIndex  = 9
                            $secondIndex    = $releaseinfo.IndexOf("Benchmark")
                            $length         = $secondIndex-$startingIndex-1
                            $releaseNumber  = $releaseinfo.Substring($startingIndex,$length) #Get CKL release number
                        }
                        $cklTitleVersionRelease = $cklTitle+$delimiter+"V"+$versionNumber+"R"+$releaseNumber
                    }
                }
                
                $sapTestBattery = $sapLookupTable.Where({$stigid -eq $_.stigid -and $_.type -eq "ckl"}  ).sapTestBattery 

                $titleMatchTest = $null
                if($stigTitle){
                    if($stigTitle -eq $sapTestBattery){
                        $titleMatchTest = $true
                    } else {
                        $titleMatchTest = $false
                    }
                }

                $fileValuesObj += [PSCustomObject]@{
                    "File Name"      = $cklFile.Name
                    "Hostname"       = $cklHOST_NAME
                    "STIG Title"     = $stigTitle
                    "STIG ID"        = $stigid
                    "Version"        = $versionNumber
                    "Release"        = $releaseNumber
                    "sapTestBattery" = $sapTestBattery
                    "Type"           = "CKL"
                    "titleMatchTest" = $titleMatchTest
                    "index"          = $cklHOST_NAME+$sapTestBattery
                }

            #endregion CKL information
        }
    }
".................[Done]"
#endregion CKL

#region xccdf
    Write-Host "Reading XCCDF files..." -NoNewline
    foreach ($xccdfFile in $xccdfFiles){
        if([System.IO.Path]::GetExtension($xccdfFile) -eq ".xml" ){ # only process xccdf files

            #get xml data for xccdf            
            [xml]$xccdfXmlDocument = get-content $xccdfFile.FullName

            #region xccdf information 
         
                $xccdfHOST_NAME = $xccdfXmlDocument.Benchmark.TestResult.target                                                 # Get xccdf host information# get the xccdf hostname            
                $xccdfStigTitle = $xccdfXmlDocument.Benchmark.title                                                             # Get xccdf stig title    
                $xccdfStigId    = ($xccdfXmlDocument.Benchmark.id).replace("xccdf_mil.disa.stig_benchmark_","")                 # Get xccdf stig id              
                $xccdfVersion   = [int]($xccdfXmlDocument.Benchmark.version.'#text').Split(".")[0]                              # Get xccdf version number
                $xccdfRelease   = [int]($xccdfXmlDocument.Benchmark.version.'#text').Split(".")[1]                              # Get xccdf release number
                $sapTestBattery = $sapLookupTable.Where({$xccdfStigId -eq $_.stigid -and $_.type -eq "xccdf"}  ).sapTestBattery # Get SAP Test battery name

                $titleMatchTest = $null
                if($xccdfStigTitle){
                    if($xccdfStigTitle -eq $sapTestBattery){
                        $titleMatchTest = $true
                    
                    } else {
                        $titleMatchTest = $false
                    
                    }
                
                }

                $fileValuesObj += [PSCustomObject]@{
                    "File Name"      = $xccdfFile.Name
                    "Hostname"       = $xccdfHOST_NAME
                    "STIG Title"     = $xccdfStigTitle
                    "STIG ID"        = $xccdfStigId
                    "Version"        = $xccdfVersion
                    "Release"        = $xccdfRelease
                    "sapTestBattery" = $sapTestBattery
                    "Type"           = "XCCDF"
                    "titleMatchTest" = $titleMatchTest
                    "index"          = $xccdfHOST_NAME+$sapTestBattery
                }

            #endregion xccdf information
        }
    }

"...............[Done]"
#endregion xccdf

#region completeness test
    Write-Host "Building Completeness Test..." -NoNewline

    foreach($line in $assessmentmethods){
    
        $lineHostname           = $line.hostname
        $lineTestBattery        = $line.testBattery
        $assessmentmethodsIndex = $lineHostname+$lineTestBattery
    
        #remove multiple matches of the test battery as being an arrray
        if ($sapLookupTable.where({$_.sapTestBattery -eq $lineTestBattery}).type -is [array]){
            $fileType = $sapLookupTable.where({$_.sapTestBattery -eq $lineTestBattery}).type[0]
        } else {
            $fileType = $sapLookupTable.where({$_.sapTestBattery -eq $lineTestBattery}).type
        }
        
        #Test if a file exists
        $fielExists = $false
        if($fileValuesObj.where({$_.index -eq $assessmentmethodsIndex})){
            $fielExists = $true
        } 
        
        $filename       = $fileValuesObj.where({$_.index -eq $assessmentmethodsIndex})."File Name"
        $stigtitle      = $fileValuesObj.where({$_.index -eq $assessmentmethodsIndex})."STIG Title"
        $Hostname       = $fileValuesObj.where({$_.index -eq $assessmentmethodsIndex}).Hostname
        $STIGID         = $fileValuesObj.where({$_.index -eq $assessmentmethodsIndex})."STIG ID"
        $Version        = $fileValuesObj.where({$_.index -eq $assessmentmethodsIndex}).Version
        $Release        = $fileValuesObj.where({$_.index -eq $assessmentmethodsIndex}).Release
        $titleMatchTest = $fileValuesObj.where({$_.index -eq $assessmentmethodsIndex}).titleMatchTest    
        
        #test for multiple files per test battery
        if($filename -is [array]) {
            $filename        = "Duplicate files found for this Test Battery"
            $stigtitle       = "Duplicate files found for this Test Battery"
            $Hostname        = "Duplicate files found for this Test Battery"
            $STIGID          = "Duplicate files found for this Test Battery"
            $Version         = "Duplicate files found for this Test Battery"
            $Release         = "Duplicate files found for this Test Battery"
            $titleMatchTest  = "Duplicate files found for this Test Battery"
            $duplicateFiles += $assessmentmethodsIndex
        } 

        if($filename.count -lt 1) {
            $filename        = "No files found for this Test Battery"
            $stigtitle       = "No files found for this Test Battery"
            $Hostname        = "No files found for this Test Battery"
            $STIGID          = "No files found for this Test Battery"
            $Version         = "No files found for this Test Battery"
            $Release         = "No files found for this Test Battery"
            $titleMatchTest  = "No files found for this Test Battery"
            $missingFiles   += $assessmentmethodsIndex

        }

        if($titleMatchTest -eq $false ){
            $wrongSTIGtitle += $assessmentmethodsIndex
        }

        #Set results object values
        $completenessTestObj += [PSCustomObject]@{
            "SAP Hostname"     = $lineHostname
            "SAP Test Battery" = $lineTestBattery
            "Type"             = $fileType
            "fielExists"       = $fielExists
            "File Name"        = $filename
            "Hostname"         = $Hostname
            "STIG Title"       = $stigtitle
            "STIG ID"          = $STIGID        
            "Version"          = $Version       
            "Release"          = $Release       
            "titleMatchTest"   = $titleMatchTest
        }
    }
"........[Done]"

#endregion completeness test 

Write-Host "Exporting files to 'output' folder" -NoNewline 
$completenessTestObj     | export-csv -Path   "$scriptRootPath\output\completenessTest.csv" -NoTypeInformation
$fileValuesObj           | export-csv -Path   "$scriptRootPath\output\fileValues.csv"       -NoTypeInformation
$fileValuesObj."STIG ID" | sort |Get-Unique > "$scriptRootPath\output\UniqueSTIGIDs.txt" 
$assessmentmethods.testBattery | sort |Get-Unique > "$scriptRootPath\output\UniqueTestBatteryList.txt" 

"...[Done]"
""
""
"Results:"
"--------"
"Total CKL files:............"+$cklFiles.count
"Total XCCDF files:.........."+$xccdfFiles.count
"Total STIG files:..........."+($cklFiles.count+$xccdfFiles.count)
"Total Test Battery lines:..."+$assessmentmethods.count
""

if($assessmentmethods.count -ne ($cklFiles.count+$xccdfFiles.count)){
    Write-Host -ForegroundColor Red "SAP test battery count does not match file count totals."
} else {
    Write-Host -ForegroundColor Green "SAP test battery count matches file count totals."
}
""
if($duplicateFiles.count -gt 0){
    Write-Host -ForegroundColor white "Duplicate files:.............."     -NoNewline
    Write-Host -ForegroundColor Red $duplicateFiles.count  
}
if($missingFiles.count -gt 0){
    Write-Host -ForegroundColor white "Missing files:................" -NoNewline
    Write-Host -ForegroundColor Red $missingFiles.count  
}
if($wrongSTIGtitle.count -gt 0){
    Write-Host -ForegroundColor white "STIG name conflicts:.........."  -NoNewline
    Write-Host -ForegroundColor Red $wrongSTIGtitle.count  
}
""
pause
