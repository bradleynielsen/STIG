Param($computer)

#region:    Config

    $Vul_ID         = "63373"
    $TestName       = "Local accounts: Password Expiration"
    $CheckValue     = !$null
    $passFail       = ""
    $failures       = @()

#endregion: Config

#region:    Scan

    try{
        $results = Invoke-Command -ComputerName $computer -ScriptBlock {

        } -ErrorAction Stop  
    }catch{
        $results = "Error"
    }

#endregion: Scan

#region:    Test Results

    foreach($result in $results){
        if ($result -like "*error*") {
            $passFail = "Error"
        }elseif ($result.enabled -eq "True" -and $result.PasswordExpires -eq $null) {
            $passFail = "Fail"
            $failures += $result
        } elseif ($result.enabled -eq "False") {
            $passFail = "Pass"
        } elseif ($result.enabled -eq "True" -and $result.PasswordExpires -ne $null) {
            $passFail = "Pass"
        }
    }

    if($failures){
        $results = $failures
        $passFail = "Fail"
    }

#endregion: Test Results

$resultsObj = [PSCustomObject]@{
    "Computer"   = $computer
    "Vul_ID"     = $Vul_ID
    "Test Name"  = $TestName
    "CheckValue" = $CheckValue
    "Value"      = $results.userName -join ', '
    "Pass/Fail"  = $passFail
}

$exportCSV = gci $PSScriptRoot\shared\exportCSV.ps1
& $exportCSV -resultsObj $resultsObj
return $resultsObj

<#

Check Content

"The default file system permissions are adequate when the Security Option 

    Network access: Let Everyone permissions apply to anonymous users 

is set to ""Disabled"" (WN10-SO-000160).


If the default file system permissions are maintained and the referenced option is set to ""Disabled"", this is not a finding.

Verify the default permissions for the sample directories below. Non-privileged groups such as Users or Authenticated Users must not have greater than Read & execute permissions except where noted as defaults. (Individual accounts must not be used to assign permissions.)

Viewing in File Explorer:
Select the ""Security"" tab, and the ""Advanced"" button.

C:\
Type - ""Allow"" for all
Inherited from - ""None"" for all
Principal - Access - Applies to
Administrators - Full control - This folder, subfolders and files
SYSTEM - Full control - This folder, subfolders and files
Users - Read & execute - This folder, subfolders and files
Authenticated Users - Modify - Subfolders and files only
Authenticated Users - Create folders / append data - This folder only

\Program Files
Type - ""Allow"" for all
Inherited from - ""None"" for all
Principal - Access - Applies to
TrustedInstaller - Full control - This folder and subfolders
SYSTEM - Modify - This folder only
SYSTEM - Full control - Subfolders and files only
Administrators - Modify - This folder only
Administrators - Full control - Subfolders and files only
Users - Read & execute - This folder, subfolders and files
CREATOR OWNER - Full control - Subfolders and files only
ALL APPLICATION PACKAGES - Read & execute - This folder, subfolders and files
ALL RESTRICTED APPLICATION PACKAGES - Read & execute - This folder, subfolders and files

\Windows
Type - ""Allow"" for all
Inherited from - ""None"" for all
Principal - Access - Applies to
TrustedInstaller - Full control - This folder and subfolders
SYSTEM - Modify - This folder only
SYSTEM - Full control - Subfolders and files only
Administrators - Modify - This folder only
Administrators - Full control - Subfolders and files only
Users - Read & execute - This folder, subfolders and files
CREATOR OWNER - Full control - Subfolders and files only
ALL APPLICATION PACKAGES - Read & execute - This folder, subfolders and files
ALL RESTRICTED APPLICATION PACKAGES - Read & execute - This folder, subfolders and files

Alternately use icacls.

Run ""CMD"" as administrator.
Enter ""icacls"" followed by the directory.

icacls c:\
icacls ""c:\program files""
icacls c:\windows

The following results will be displayed as each is entered:

c:\
BUILTIN\Administrators:(OI)(CI)(F)
NT AUTHORITY\SYSTEM:(OI)(CI)(F)
BUILTIN\Users:(OI)(CI)(RX)
NT AUTHORITY\Authenticated Users:(OI)(CI)(IO)(M)
NT AUTHORITY\Authenticated Users:(AD)
Mandatory Label\High Mandatory Level:(OI)(NP)(IO)(NW)
Successfully processed 1 files; Failed processing 0 files

c:\program files 
NT SERVICE\TrustedInstaller:(F)
NT SERVICE\TrustedInstaller:(CI)(IO)(F)
NT AUTHORITY\SYSTEM:(M)
NT AUTHORITY\SYSTEM:(OI)(CI)(IO)(F)
BUILTIN\Administrators:(M)
BUILTIN\Administrators:(OI)(CI)(IO)(F)
BUILTIN\Users:(RX)
BUILTIN\Users:(OI)(CI)(IO)(GR,GE)
CREATOR OWNER:(OI)(CI)(IO)(F)
APPLICATION PACKAGE AUTHORITY\ALL APPLICATION PACKAGES:(RX)
APPLICATION PACKAGE AUTHORITY\ALL APPLICATION PACKAGES:(OI)(CI)(IO)(GR,GE)
APPLICATION PACKAGE AUTHORITY\ALL RESTRICTED APPLICATION PACKAGES:(RX)
APPLICATION PACKAGE AUTHORITY\ALL RESTRICTED APPLICATION PACKAGES:(OI)(CI)(IO)(GR,GE)
Successfully processed 1 files; Failed processing 0 files

c:\windows
NT SERVICE\TrustedInstaller:(F)
NT SERVICE\TrustedInstaller:(CI)(IO)(F)
NT AUTHORITY\SYSTEM:(M)
NT AUTHORITY\SYSTEM:(OI)(CI)(IO)(F)
BUILTIN\Administrators:(M)
BUILTIN\Administrators:(OI)(CI)(IO)(F)
BUILTIN\Users:(RX)
BUILTIN\Users:(OI)(CI)(IO)(GR,GE)
CREATOR OWNER:(OI)(CI)(IO)(F)
APPLICATION PACKAGE AUTHORITY\ALL APPLICATION PACKAGES:(RX)
APPLICATION PACKAGE AUTHORITY\ALL APPLICATION PACKAGES:(OI)(CI)(IO)(GR,GE)
APPLICATION PACKAGE AUTHORITY\ALL RESTRICTED APPLICATION PACKAGES:(RX)
APPLICATION PACKAGE AUTHORITY\ALL RESTRICTED APPLICATION PACKAGES:(OI)(CI)(IO)(GR,GE)
Successfully processed 1 files; Failed processing 0 files"


#>
