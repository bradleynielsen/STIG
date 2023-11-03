<#
Rename xccdf

File name
MS Windows Server 2019 STIG_V2R3_CERS-VLAB-CAD2_20220321

Convention
Delimiter: "_"
STIG title_VxRX_system_hostname_YYYYMMDD

#>


#region config

    $systemName   = ""     #<<<<<<< Set system name here
    $delimiter    = " "    #<<<<<<< Set delimiter name here
    $subDirOption = $false #<<<<<<< Set option for subdirectory [ $true | $false ] - Set to $true If you want you files grouped by STIG ID

#endregion config


#init
    $scriptRootPath     = $PSScriptRoot  # relative path where the script is     
    remove-item $scriptRootPath\updated\* -Recurse -Include *
#endregion init


#get list of xccdf files
$xccdfFiles   = Get-ChildItem "$scriptRootPath\old"


#region xccdf file loop

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


                if($subDirOption -eq $true) {

                    $xccdfUpdateDirectory = "$scriptRootPath\updated\$stigid" # directory for new files in sub directory

                    #create a stig folder
                    if(!(test-path $xccdfUpdateDirectory)){
                        mkdir $scriptRootPath/updated/$stigid
                    }

                } else {

                    $xccdfUpdateDirectory = "$scriptRootPath\updated" # directory for new files without sub directory

                }

            
                # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ARRANGE FILE NAME HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                # comment/uncomment the rows to configure how the name will be  OR  make your own 

                # [HOSTNAME]_STIG_DATE-XCCDF.xml
                $newFileName = $xccdfHOST_NAME + $delimiter + $xccdfTitleVersionRelease + $delimiter + $date + "-XCCDF.xml"

                # STIG_[HOSTNAME]_DATE-XCCDF.xml
                #$newFileName = $xccdfTitleVersionRelease + $delimiter + "[" + $xccdfHOST_NAME + "]" + $delimiter + $date + "-XCCDF.xml"
            
                # STIG-HOSTNAME-XCCDF.xml
                #$newFileName =   $stigid+"-"+$xccdfHOST_NAME+"-"+"-XCCDF.xml"

                # HOSTNAME-STIG-XCCDF.xml
                #$newFileName =   $xccdfHOST_NAME+"-"+$stigid+"-XCCDF.xml"


                # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ARRANGE FILE NAME HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            
            
                #create new file
                $destination = $xccdfUpdateDirectory + "\" + $newFileName 
                write-host -ForegroundColor green "Making file: " -NoNewline
                write-host -ForegroundColor white $newFileName
                Copy-Item -Path $xccdfFile.FullName -Destination $destination

            #endregion rename file
        }
    }
#endregion xccdf file loop
write-host -BackgroundColor Black -ForegroundColor yellow "Your files are in the 'updated' folder"
