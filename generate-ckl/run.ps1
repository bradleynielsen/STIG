#region Read Me
<#
Title          : generate-ckl 
Compatable with: DISA STIG Viewer :: 2.17

#>
# endregion Read Me

#region init

    $scriptRootPath     = $PSScriptRoot  # relative path where the script is     
    $count = 0

    #test if source file directories exist

    $xccdfPathStatus         = Test-Path "$scriptRootPath\xccdf"
    $ckl_templatesPathStatus = Test-Path "$scriptRootPath\ckl_templates"


    # If DIR exists, get list of files | else make them and get the list
    if ($xccdfPathStatus -and $ckl_templatesPathStatus){
        $xccdfFiles   = Get-ChildItem "$scriptRootPath\xccdf"
        $cklTemplates = Get-ChildItem "$scriptRootPath\ckl_templates"
    } else{
        mkdir xccdf, ckl_templates -ErrorAction SilentlyContinue
        $xccdfFiles   = Get-ChildItem "$scriptRootPath\xccdf"
        $cklTemplates = Get-ChildItem "$scriptRootPath\ckl_templates"
        "CKL and XCCDF directories made. Move files into directories now and re-run script"        
        exit
    }

#endregion init

#region xccdf loop

foreach ($xccdfFile in $xccdfFiles){
    if([System.IO.Path]::GetExtension($xccdfFile) -eq ".xml" ){ # only process xccdf files
        #region xccdf information  

            #get xml data for xccdf            
            [xml]$xccdfXmlDocument = get-content $xccdfFile.FullName

            #get date of scan
            $timeValue  = ($xccdfXmlDocument.Benchmark.TestResult.'rule-result'[0].time)
            $dateIndex  = $timeValue.IndexOf("T") 
            $date       = $timeValue.substring(0, $dateIndex)


            # get the xccdf target facts            
            $xccdf_HOST_NAME = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:host_name'}).'#text' # host name
            $xccdf_HOST_IP   = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:ipv4'     }).'#text' # ipv4
            $xccdf_HOST_MAC  = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:mac'      }).'#text' # mac
            $xccdf_HOST_FQDN = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:fqdn'     }).'#text' # fqdn
            $xccdf_ROLE      = ($xccdfXmlDocument.Benchmark.TestResult.'target-facts'.fact | Where-Object {$_.name -eq 'urn:scap:fact:asset:identifier:role'     }).'#text' # role

        
            # get the xccdf stig id              
            $xccdfStigid = ($xccdfXmlDocument.Benchmark.id).replace("xccdf_mil.disa.stig_benchmark_","")

        #endregion xccdf information

        #region ckl loop 
         
            foreach ($cklTemplate in $cklTemplates) {
            
                ($cklXmlDocument = [xml]::new()).Load((Convert-Path -LiteralPath $cklTemplate.FullName))
                $cklXmlDocument.PreserveWhitespace = $true
            
                $cklTemplateStigId = $cklXmlDocument.CHECKLIST.STIGS.iSTIG.STIG_INFO.SI_DATA[3].SID_DATA #get stig id from the [3] element in STIG_INFO
                
                #region create CKL 

                    if($cklTemplateStigid -eq  $xccdfStigid){ #Make a CKL if there is a match

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

                            
                                #"xccdf_ROLE        "+                  $xccdf_ROLE
                                #"xccdf_HOST_NAME   "+                  $xccdf_HOST_NAME
                                #"xccdf_HOST_IP     "+                  $xccdf_HOST_IP   
                                #"xccdf_HOST_MAC    "+                  $xccdf_HOST_MAC  
                                #"xccdf_HOST_FQDN   "+                  $xccdf_HOST_FQDN 
                                #"cklTemplateStigId "+                  $cklTemplateStigId 
                                #""

                                $cklXmlDocument.CHECKLIST.ASSET.ROLE        = $xccdf_ROLE
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_NAME   = $xccdf_HOST_NAME.ToString()
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_IP     = $xccdf_HOST_IP   
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_MAC    = $xccdf_HOST_MAC  
                                $cklXmlDocument.CHECKLIST.ASSET.HOST_FQDN   = $xccdf_HOST_FQDN 
                                try{$cklXmlDocument.CHECKLIST.ASSET.HOST_IP = $xccdf_HOST_IP}catch{break}

                            #endregion host info

                            #region set CKL vulns

                                foreach( $Vuln in $cklXmlDocument.CHECKLIST.STIGS.iSTIG.VULN ){
                                
                                    #get id ; stig data is an array of objects
                                    foreach($object in $Vuln.STIG_DATA) {
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
                                            if ($xccdfresult -eq "pass"){
                                                $xccdfresult = "NotAFinding"
                                            }
                                                
                                            if ($xccdfresult -eq "fail"){
                                                $xccdfresult = "Open"
                                            }

                                            if ($xccdfresult -eq "notapplicable"){
                                                $xccdfresult = "Not_Applicable"
                                            }

                                            $FINDING_DETAILS = "Reviewed by SCC tool `n Result: $xccdfresult `n Date of scan: $xccdftime `n version: $xccdfversion"

                                            #set CKL attributes 
                                            Write-Host "Creating CKL for Host: $xccdf_HOST_NAME STIG: $xccdfStigid Setting results for $cklRule_ID " -NoNewline
                                            Write-Host $result.result
                                                                                               
                                            $Vuln.STATUS          = $xccdfresult
                                            $Vuln.FINDING_DETAILS = $FINDING_DETAILS
                                                   
                                        } 
                                    } #end xccdf results loop
                                }
                            #endregion set CKL vulns

                            $cklFilename = $cklTemplateStigid +" - "+ $xccdf_HOST_NAME 
                            $cklSaveLocation = "$scriptRootPath\ckl_results\"+$cklFilename+".ckl"
                            $cklXmlDocument.Save($cklSaveLocation)
                    }
                     else {}

                #endregion create CKL
            }
        #endregion ckl loop
    }
}
#endregion xccdf loop


