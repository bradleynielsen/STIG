<#
File name
MS Windows Server 2019 STIG_V2R3_CERS-VLAB-CAD2_20220321

Convention
Delimiter: "_"
STIG title_VxRX_system_hostname_YYYYMMDD

#>

#region config

$systemName = "(CUI)CNIC_N6S_PSS_NESS-Lenel"   #<<<<<<< SET SYSTEM NAME HERE
$delimiter  = "_"                              #<<<<<<< SET the seperator here

#endregion config

#init
$date               = Get-Date -Format yyyy-MM-dd
$scriptRootPath     = $PSScriptRoot                       # relative path where the script is 
$cklUpdateDirectory = "$scriptRootPath\updated ckl files" # directory for new files
$resultsObj         = @()
$cklUpdateDirectory | ls | Remove-Item 


#get list of ckl files
$cklFiles   = Get-ChildItem "$scriptRootPath\ckl"
"Processing..."
foreach ($cklFile in $cklFiles){

    if([System.IO.Path]::GetExtension($cklFile) -eq ".ckl" ){ # only process ckl files

        #get xml data for ckl            
        [xml]$cklXmlDocument = get-content $cklFile.FullName

        #region CKL information        
            
            $cklHOST_NAME = $cklXmlDocument.CHECKLIST.ASSET.HOST_NAME    #get CKL host information
        
            # get the CKL title and version 
            $STIG_INFO = $cklXmlDocument.CHECKLIST.STIGS.iSTIG.STIG_INFO  # STIG_INFO has an element called "title" that is the name of the STIG
            foreach ($SI_DATA in $STIG_INFO) {
                foreach ($element in $SI_DATA.SI_DATA){

                    if($element.SID_NAME -eq "version"){
                        $versionNumber = $element.SID_DATA            # Get CKL version number
                    }

                    if($element.SID_NAME -eq "stigid"){               # Get CKL title
                        $stigid   = $element.SID_DATA
                        $cklTitle = $stigid.replace("_"," ")

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

            $resultsObj += [PSCustomObject]@{
                "Original Name" = $cklFile.BaseName
                "Hostname"      = $cklHOST_NAME
                "STIG"          = $cklTitleVersionRelease
            }
        
        #endregion CKL information


        #region rename file

            # <<<<<< ARRANGE FILE NAME HERE >>>>>>>>
            #$destination = $cklUpdateDirectory+"\"+$cklTitleVersionRelease+$delimiter+$cklHOST_NAME+$delimiter+$date+".ckl"
            #$destination = $cklUpdateDirectory+"\"+$cklHOST_NAME+$cklTitleVersionRelease+$delimiter+$delimiter+$date+".ckl"
            $destination = $cklUpdateDirectory+"\"+$systemName+$delimiter+$cklHOST_NAME+$delimiter+$cklTitleVersionRelease+$delimiter+$date+".ckl"

            Copy-Item -Path $cklFile.FullName -Destination $destination

        #endregion rename file
    }
}
"Done."
" "
"Totals"
"------"
"Number of original files: " + $cklFiles.Count
"Number of renamed files:  " + ($cklUpdateDirectory|ls).count
" "
"Results:"
$resultsObj
$resultsObj | export-csv -Path "$scriptRootPath\results.csv" -NoTypeInformation
