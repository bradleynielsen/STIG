
#"DataTables_Table_0_length"

$scriptRootPath =  $PSScriptRoot


$webAddress =  'https://public.cyber.mil/stigs/downloads'
$webPage = Invoke-WebRequest -Uri $webAddress 

#$fileDiv = $webPage.ParsedHtml.getElementsByClassName("file") 
#$innerHTML = $tableDiv[0].innerHTML | ConvertTo-Html

$downloadTable = $webPage.ParsedHtml.getElementsByClassName("downloadTable") 
$downloadTable = $webPage.ParsedHtml.getElementsByTagName("file") 

$trDivs = $webPage.ParsedHtml.IHTMLDocument3_getElementsByTagName("tr")


$results = @()


function convertForDate($innerText){
    try{
        $date = $innerText
        #$date.Replace(" ","-")
        $value = [datetime]::parseexact($date.trim(), 'yyyy MM dd', $null)
    }catch{
        $value = $innerText
    }
    return $object
}



foreach ($tr in $trDivs){
    
    $trChildren = $tr.children

    foreach ($td in $trChildren){
        $tdChildren = $td.children
        $lineObject = [PSCustomObject]@{
            title = ''
            date  = ''
        }
        
        
        #set title
        if ($td.className -eq "title_column" ){
            $keyName = $td.className
            foreach($tdChild in $tdChildren){
                if ($tdChild.tagName -eq "span" ){
                     $titleValue = $tdChild.innerText
                }
            }
        }


        #set date
        if ($td.className -eq "updated_column" ){
            $keyName    = $td.className
            foreach($tdChild in $tdChildren){
                if ($tdChild.tagName -eq "span" ){
                    $dateValue = $tdChild.innerText
                    $dateValue = ($dateValue.Trim()).Replace(" ","-")
                }
            }
        }



    }
    $lineObject.title = $titleValue 
    $lineObject.date  = $dateValue
    $lineObject
    $results +=     $lineObject
}

$results | Sort-Object -Property date -Descending  | export-csv -Path   "$scriptRootPath\disaStigList.csv" -NoTypeInformation