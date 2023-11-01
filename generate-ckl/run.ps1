


#region config
#endregion config


#init

    $scriptRootPath     = $PSScriptRoot  # relative path where the script is     

#endregion init


#get list of xccdf files
$xccdfFiles   = Get-ChildItem "$scriptRootPath\xccdf"
$cklTemplates = Get-ChildItem "$scriptRootPath\ckl_templates"


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
            $xccdfStigid = ($xccdfXmlDocument.Benchmark.id).replace("xccdf_mil.disa.stig_benchmark_","")



        
        #endregion xccdf information


        #region rename file



        #endregion rename file
    }
}

