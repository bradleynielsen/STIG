cls
""
""
""
""
""
""
""
"             Testing connection to computers          "
"========================================================"
$comp             = Get-ADComputer $env:COMPUTERNAME
$ou               = $comp.DistinguishedName
$index            = $ou.IndexOf("=BDSC,")-2
$base             = $ou.Substring($index)
$list             = @(get-adcomputer -SearchBase $base -Filter * -Properties * | select-object -ExpandProperty name)
$i                = $list.count
$j                = 1
$ping             = $false
$online           = @()

foreach ( $computer in $list ){
    $pingProgress = $j/$i * 100
    Write-Progress -Activity "Finding online hosts..." -PercentComplete $pingProgress
    Write-Host "$computer..." -NoNewline
    
    testnetconnection($computer)

    if ($tnc){
        $online += $computer
        Write-Host " Online" -ForegroundColor Green
    } else {
        Write-Host " Offline" -ForegroundColor red
    }
    $j++   
}

$online | ConvertTo-Csv -NoTypeInformation | clip





function testnetconnection{
    $tnc = tnc $computer -InformationLevel Quiet -WarningAction SilentlyContinue
    $tnc
}