$download = $false


#"DataTables_Table_0_length"
Remove-Variable -Name * -ErrorAction SilentlyContinue
#$titleValue = $null
cls
$scriptRootPath =  $PSScriptRoot
try{mkdir $scriptRootPath\download -ErrorAction SilentlyContinue}catch{}
$webAddress =  'https://public.cyber.mil/stigs/downloads'
$webPage = Invoke-WebRequest -Uri $webAddress 


$trDivs = $webPage.ParsedHtml.IHTMLDocument3_getElementsByTagName("tr")

$results = @()

$lineObject = [PSCustomObject]@{
    title = '-'
    date  = '-'
    link  = '-'
}
foreach ($tr in $trDivs){
    
    $trChildren = $tr.children
    foreach ($td in $trChildren){

        $tdChildren = $td.children
        
        #set title and download link
        if ($td.className -eq "title_column" ){
            $keyName = $td.className
            foreach($tdChild in $tdChildren){
                if ($tdChild.tagName -eq "span" ){
                     $titleValue = $tdChild.innerText
                }
                if ($tdChild.tagName -eq "A" ){
                     $linkValue = $tdChild.href
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
    $lineObject.link  = $linkValue
    #$lineObject
    $results +=     $lineObject
    $uri = $lineObject.link

    if ($titleValue){
        if($download -eq $true){
            $pathIndex = (($uri.Split("/")).count) - 1
            $nameArray = $uri.Split("/")
            $filename  = $nameArray[$pathIndex]
            $dlPath = $scriptRootPath+"\download\"+$filename
            "downloading $titleValue"
            Invoke-WebRequest -URI $uri -OutFile $dlPath
            Start-Sleep -Seconds 1
        }
    }
}
"writing csv fiele to 'disaStigList.csv'"
$results | Sort-Object -Property date -Descending  | export-csv -Path   "$scriptRootPath\disaStigList.csv" -NoTypeInformation

#$dlPath = $env:HOMEPATH+"\tempsfdsadf.bin"
#(New-Object System.Net.WebClient).DownloadFile($uri, $dlPath)