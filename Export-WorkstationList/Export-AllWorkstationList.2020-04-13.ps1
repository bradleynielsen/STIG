$date               = get-date -Format yyyy-MM-dd
$base               = "BDSC" # <<<<< change your base here
$comp               = Get-ADComputer $env:COMPUTERNAME
$ou                 = $comp.DistinguishedName
$index              = $ou.IndexOf("=$base,")-2
$SearchBase         = $ou.Substring($index)
$server             = (Get-ADDomainController).name
$list               = @(get-adcomputer -SearchBase $SearchBase -Server $server -Filter * -Properties * | select-object -ExpandProperty name)
$resultsTable       = @()
$ProgressPreference = 'SilentlyContinue'


function makeComputerObject{
    [pscustomobject]@{
        "Computer Name" = $computer
        "Date        "  = $date
        "Status"        = $status
    }
}



""
""
""
""
""
"     Testing Connections"
"============================="



foreach ( $computer in $list ){
    Write-Host "$computer..." -NoNewline
    $ping = ping $computer /n 1 /w 2
    if ($?){
        Write-Host " Online" -ForegroundColor Green
        $status         = "Online"
        $computerObject = makeComputerObject($computer,$date,$status)
    } else {
        Write-Host " Offline" -ForegroundColor red
        $status         = "Offline"
        $computerObject = makeComputerObject($computer,$date,$status)
    }
    $resultsTable += $computerObject
}

$resultsTable
""
"Exporting results"
$resultsTable | Export-Csv -Path $PSScriptRoot\workstationstatus.$date.csv -NoTypeInformation
""
"Done."

explorer $PSScriptRoot


<#

""
"================================="
write-host "Total Online:  " -NoNewline
$online.Count 
""
write-host "Total Offline: " -NoNewline
$offline.Count 
""
write-host "Total        : " -NoNewline
$offline.Count+$online.Count 
#>






$ProgressPreference = 'Continue'
