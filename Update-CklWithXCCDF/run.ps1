cls
#region Read Me
<#
Title          : generate-ckl 
Compatable with: DISA STIG Viewer :: 2.17

#>
# endregion Read Me

#region config

    $systemName = "(CUI)CNIC_N6S_PSS_NESS-Lenel"   #<<<<<<< SET SYSTEM NAME HERE
    $delimiter  = "_"                              #<<<<<<< SET the seperator here



    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $appendOption = $null
    $appendOption = [System.Windows.Forms.MessageBox]::Show('Click Yes to append, No to overwrite' , "Append XCCDF resutls to CKL?" , 4)





#endregion config

#region init

    $scriptRootPath = $PSScriptRoot  # relative path where the script is     
    $cklFiles       = Get-ChildItem "$scriptRootPath\initial_files\ckl"
    
#endregion init

#region ckl loop 
    #"ckl loop"
    foreach ($cklFile in $cklFiles) {
        #"getting xccdf files"        
        $xccdfFiles = Get-ChildItem "$scriptRootPath\initial_files\xccdf"
        #init the date
        $date = Get-Date -Format yyyy-MM-dd
        #"loading ckl xml info"        
        ($cklXmlDocument = [xml]::new()).Load((Convert-Path -LiteralPath $cklFile.FullName))
        $cklXmlDocument.PreserveWhitespace = $true
        #"fetching stig id"        
        #STIG_ID
        $cklStigId = ($cklXmlDocument.CHECKLIST.STIGS.iSTIG.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq 'stigid'}).sid_data #get stig id from the element STIG_INFO
        #"fetching host id"        

        #HOST_ID
        $cklHOST_ID = $cklXmlDocument.CHECKLIST.ASSET.HOST_NAME

        $statusString = "Processing $cklHOST_ID - $cklStigId..." 
        Write-Host $statusString -NoNewline

        #"starting xccdf file loop"
        #region xccdf loop
            foreach ($xccdfFile in $xccdfFiles){

                if([System.IO.Path]::GetExtension($xccdfFile) -eq ".xml" -and $xccdfFile.BaseName -like "*XCCDF*"){ # only process xccdf files
                    
                    #region xccdf information  

                        #get xml data for xccdf            
                        [xml]$xccdfXmlDocument = get-content $xccdfFile.FullName

                        # get the xccdf details
                        $xccdfStigid     = ($xccdfXmlDocument.Benchmark.id).replace("xccdf_mil.disa.stig_benchmark_","")
                        $xccdf_HOST_NAME = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:host_name'}).'#text' # host name
                        
                    #endregion xccdf information

                    #region create CKL 

                        if($cklStigId -eq  $xccdfStigid -and $cklHOST_ID -eq $xccdf_HOST_NAME){ #Make a CKL if there is a match
                            
                            # get the xccdf details
                            $xccdf_HOST_IP   = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:ipv4'     }).'#text' # ipv4
                            $xccdf_HOST_MAC  = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:mac'      }).'#text' # mac
                            $xccdf_HOST_FQDN = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:fqdn'     }).'#text' # fqdn
                            $xccdf_ROLE      = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:role'     }).'#text' # role

                            #get date of scan
                            $timeValue  = ($xccdfXmlDocument.Benchmark.TestResult.'rule-result'[0].time)
                            $dateIndex  = $timeValue.IndexOf("T") 
                            $date       = $timeValue.substring(0, $dateIndex)

                            #region host info

                                #Clean up variables to be empty strings, not null or array

                                #CHECK ROLE
                                if($xccdf_ROLE -eq $null){
                                    $xccdf_ROLE = "None"
                                } 
                                if($xccdf_HOST_IP -eq $null){
                                    $xccdf_HOST_IP = ""
                                } 
                                if ( $xccdf_HOST_IP -is [array] )  {
                                    $xccdf_HOST_IP = $xccdf_HOST_IP[0]
                                }
                                if ($xccdf_HOST_MAC -eq $null){
                                    $xccdf_HOST_MAC = ""
                                }
                                if ( $xccdf_HOST_MAC -is [array] )  {
                                    $xccdf_HOST_MAC = $xccdf_HOST_MAC[0]
                                }

                                $statusString = " [Building new CKL] " 
                                Write-Host $statusString -NoNewline                            

                                $cklXmlDocument.CHECKLIST.ASSET.ROLE        = $xccdf_ROLE
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_NAME   = $xccdf_HOST_NAME.ToString()
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_IP     = $xccdf_HOST_IP   
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_MAC    = $xccdf_HOST_MAC  
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_FQDN   = $xccdf_HOST_FQDN 
                                try{
                                    $cklXmlDocument.CHECKLIST.ASSET.HOST_IP = $xccdf_HOST_IP
                                }catch{
                                    Write-Host -ForegroundColor red    "Cannot load IP from XCCDF"
                                    break
                                }

                            #endregion host info

                            #region set CKL vulns
                                #"starting ckl Vuln loop"

                                foreach( $cklVuln in $cklXmlDocument.CHECKLIST.STIGS.iSTIG.VULN ){
                                    
                                    #get id ; stig data is an array of objects
                                    foreach($object in $cklVuln.STIG_DATA) {
                                        if ( $object.VULN_ATTRIBUTE -eq "Rule_ID"){
                                            $cklRule_ID = $object.ATTRIBUTE_DATA
                                        }
                                    }
                                    
                                    #loop over xccdf results and set the corresponding CKL vuln status
                                    foreach ( $result in $xccdfXmlDocument.Benchmark.TestResult.'rule-result' ){

                                        $xccdfidref    = $result.idref.Replace("xccdf_mil.disa.stig_rule_","")   
                                        $xccdfrole     = $result.role    
                                        $xccdftime     = $result.time    
                                        $xccdfresult   = $result.result  
                                        $xccdcci       = $result.ident.'#text' | Select-String 'cci'
                                        $xccdfmessage  = $result.message 
                                        $xccdffix      = $result.fix     
                                        $xccdfcheck    = $result.check   
                                        $xccdfversion  = $result.version   

                                        if($xccdfidref -eq $cklRule_ID ){ #match the rule ids
                                            
                                            #translate xccdr result to CKL syntax 
                                            if ($xccdfresult -eq "pass"){
                                                $xccdfresult = "NotAFinding"
                                            }
                                                
                                            if ($xccdfresult -eq "fail"){
                                                $xccdfresult = "Open"
                                            }

                                            if ($xccdfresult -eq "notapplicable"){
                                                $xccdfresult = "Not_Applicable"
                                            }


                                            #region update CKL
                                                $FINDING_DETAILS = "Reviewed by SCC tool`nResult: $xccdfresult`nDate of scan: $xccdftime`nversion: $xccdfversion"

                                                if ($appendOption -eq "Yes"){
                                                    $cklVuln.FINDING_DETAILS += "`n`n"+ $FINDING_DETAILS
                                                }else{
                                                    $cklVuln.FINDING_DETAILS = $FINDING_DETAILS
                                                }

                                                $cklVuln.STATUS = $xccdfresult

                                            #endregion update CKL
                                        } 
                                    } #end xccdf results loop
                                }
                            #endregion set CKL vulns
                                
                            #write the new file <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                            $statusString = " [Writing new file] "
                            Write-Host $statusString -NoNewline

                            $cklFilename     = $systemName + $delimiter +  $cklHOST_ID + $delimiter + $cklStigId + $delimiter + $date
                            $cklSaveLocation = "$scriptRootPath\results\ckl\"+$cklFilename+".ckl"
                            $cklXmlDocument.Save($cklSaveLocation)

                            $statusString = " [Moving XCCDF file] "
                            Write-Host $statusString -NoNewline

                            $xccdfFile  | Move-Item -Destination $scriptRootPath\results\xccdf


                            Write-Host -ForegroundColor Green " [Done] " 

                        } else {}
                    #endregion create CKL
                }
            }
        #endregion xccdf loop        
    }
#endregion ckl loop
















