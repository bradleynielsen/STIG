


#region config
#endregion config


#init

    $scriptRootPath     = $PSScriptRoot  # relative path where the script is     

#endregion init


#functions
    

#endregion functions


#get list of xccdf files
$xccdfFiles   = Get-ChildItem "$scriptRootPath\xccdf"
$cklTemplates = Get-ChildItem "$scriptRootPath\ckl_templates"


foreach ($xccdfFile in $xccdfFiles){
    if([System.IO.Path]::GetExtension($xccdfFile) -eq ".xml" ){ # only process xccdf files
        #region xccdf information  

            #get xml data for xccdf            
            [xml]$xccdfXmlDocument = get-content $xccdfFile.FullName

            #get date of scan
            $timeValue  = ($xccdfXmlDocument.Benchmark.TestResult.'rule-result'[0].time)
            $dateIndex  = $timeValue.IndexOf("T") 
            $date       = $timeValue.substring(0, $dateIndex)


            # get the xccdf hostname            
            $xccdfHOST_NAME = $xccdfXmlDocument.Benchmark.TestResult.target   #get xccdf host information
        
            # get the xccdf stig id              
            $xccdfStigid = ($xccdfXmlDocument.Benchmark.id).replace("xccdf_mil.disa.stig_benchmark_","")
            $xccdfStigid

        #endregion xccdf information


        foreach ($cklTemplate in $cklTemplates) {
            "templates"
            [xml]$cklXmlDocument = get-content $cklTemplate.FullName
            $cklTemplateStigid = $cklXmlDocument.CHECKLIST.STIGS.iSTIG.STIG_INFO.SI_DATA[3].SID_DATA #get stig id from the [3] element in STIG_INFO
            
            #if the stig id's match, generate a ckl
            if($cklTemplateStigid -eq  $xccdfStigid){
                


            }
              
        }







    }
}









# Since there are multiple elements that need to be 
# changed use a foreach loop
foreach ($element in $xmlDoc.config.button)
{
    $element.command = "C:\Prog32\folder\test.jar"
}
    
# Then you can save that back to the xml file
$xmlDoc.Save("c:\savelocation.xml")