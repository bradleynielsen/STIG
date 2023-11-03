#region Read Me
<#
Title          : generate-ckl 
Compatable with: DISA STIG Viewer :: 2.17

#>
# endregion Read Me



#region config
#endregion config


#region init

    $scriptRootPath     = $PSScriptRoot  # relative path where the script is     
    $count = 0

#endregion init


#region functions
    

#endregion functions


#get list of xccdf files
$xccdfFiles   = Get-ChildItem "$scriptRootPath\xccdf"
$cklTemplates = Get-ChildItem "$scriptRootPath\ckl_templates"

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
            
                if($cklTemplateStigid -eq  $xccdfStigid){ #Make a CKL if there is a match
                    $count += 1
                    "match count " +$count
                    #region create CKL

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

                        $cklFilename = $cklTemplateStigid +" - "+ $xccdf_HOST_NAME 

                        $cklSaveLocation = "$scriptRootPath\ckl_results\"+$cklFilename+".ckl"
                        $cklXmlDocument.Save($cklSaveLocation)

                    #endregion create CKL
                } else {}

            }
        #endregion ckl loop
    }
}
#endregion xccdf loop




<#


# Read the existing file
[xml]$xmlDoc = Get-Content $xmlFileName

# If it was one specific element you can just do like so:
$xmlDoc.config.button.command = "C:\Prog32\folder\test.jar"
# however this wont work since there are multiple elements

# Since there are multiple elements that need to be 
# changed use a foreach loop
foreach ($element in $xmlDoc.config.button)
{
    $element.command = "C:\Prog32\folder\test.jar"
}
    
# Then you can save that back to the xml file
$xmlDoc.Save("c:\savelocation.xml")






$orange = $xml.Fruits.Fruit | ? { [int]$_.Code -eq 2 }

#>

