<#


#>


#region config




#endregion config


#init
$date               = Get-Date -Format yyyy-MM-dd
$scriptRootPath = $PSScriptRoot
$xmlDirectory = "$scriptRootPath\xml" # directory of files
$csvOuputArray = @()


#get list of ckl files
$files   = Get-ChildItem $xmlDirectory

$files 

foreach ($file in $files){
    
    #get xml data for ckl            
    [xml]$xmlParse = get-content $file.FullName
    [xml]$OuterXml = $xmlParse.Benchmark.OuterXml
    $groups = $OuterXml.Benchmark.Group
    $lookupTable = @()
    $stigTitle = $xmlParse.Benchmark.title
    $stigTitle
    foreach ($group in $groups){
        [xml]$groupOuterXml = $group.OuterXml
        
        $cciList   = @()
        $identList = $groupOuterXml.Group.Rule.ident

        #get the CCI info
        foreach ($ident in $identList){
            if ($ident.system -eq "http://cyber.mil/cci"){
                $cciList += $ident.'#text'
            }
        }

        $vulnID = $group.id
        $ruleID = $groupOuterXml.Group.Rule.id

        $resultsObj = [PSCustomObject]@{
            "STIG Title" = $stigTitle
            "Vuln ID"    = $vulnID
            "Rule ID"    = $ruleID
            "CCI"        = $cciList -join '; '
        }

        $lookupTable += $resultsObj
    }


    $csvOuputArray += $lookupTable
    
    
}

$csvOuputArray | Export-Csv -Path "$PSScriptRoot/output.csv" -NoTypeInformation