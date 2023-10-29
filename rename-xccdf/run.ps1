<#
File name
MS Windows Server 2019 STIG_V2R3_CERS-VLAB-CAD2_20220321

Convention
Delimiter: "_"
STIG title_VxRX_system_hostname_YYYYMMDD

#>


#region config

    $systemName = ""   #<<<<<<< SET SYSTEM NAME HERE
    $delimiter  = " "

#endregion config


#init
    $scriptRootPath     = $PSScriptRoot  # relative path where the script is     
    remove-item $scriptRootPath\updated\* -Recurse -Include *
    Pause
#endregion init


#get list of xccdf files
$xccdfFiles   = Get-ChildItem "$scriptRootPath\old"

foreach ($xccdfFile in $xccdfFiles){
    if([System.IO.Path]::GetExtension($xccdfFile) -eq ".xml" ){ # only process xccdf files

        #get xml data for xccdf            
        [xml]$xccdfXmlDocument = get-content $xccdfFile.FullName

        #get date of scan
        $timeValue  = ($xccdfXmlDocument.Benchmark.TestResult.'rule-result'[0].time)
        $dateIndex  = $timeValue.IndexOf("T") 
        $date       = $timeValue.substring(0, $dateIndex)

        #region xccdf information  

            # get the xccdf hostname            
            $xccdfHOST_NAME = $xccdfXmlDocument.Benchmark.TestResult.target   #get xccdf host information
        
            # get the xccdf stig id              
            $stigid = ($xccdfXmlDocument.Benchmark.id).replace("xccdf_mil.disa.stig_benchmark_","")

            # get the xccdf version             
            $xccdfRelease = $xccdfXmlDocument.Benchmark.version.'#text'      # Get xccdf version number

            $xccdfTitleVersionRelease = $stigid+$delimiter+$xccdfRelease

            #"Processing $xccdfHOST_NAME $xccdfTitleVersionRelease"
        
        #endregion xccdf information


        #region rename file


            $xccdfUpdateDirectory = "$scriptRootPath\updated\$stigid" # directory for new files
            
            #create a stig folder
            if(!(test-path $xccdfUpdateDirectory)){
                mkdir $PSScriptRoot/updated/$stigid
            }
            
            # <<<<<<<<<<<<<<<<<<<<<<< ARRANGE FILE NAME HERE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            $destination = $xccdfUpdateDirectory + "\" + $xccdfTitleVersionRelease + $delimiter + "[" + $xccdfHOST_NAME + "]" + $delimiter + $date + "-XCCDF.xml"

            Copy-Item -Path $xccdfFile.FullName -Destination $destination

        #endregion rename file
    }
}

