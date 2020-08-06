Param(
    $computer
)

#region:    Config

    $Vul_ID     = "77189"
    $TestName   = "Get-ProcessMitigation Acrobat.exe"
    $CheckValue = "DEP.Enable;ASLR.BottomUp;ASLR.ForceRelocateImages;Payload.EnableExportAddressFilter;Payload.EnableExportAddressFilterPlus;Payload.EnableImportAddressFilter;Payload.EnableRopStackPivot;Payload.EnableRopCallerCheck;Payload.EnableRopSimExec"
    $datestamp  = (Get-Date -DisplayHint Time).ToString().Replace("/","-").Replace(":","").Replace(" AM","").Replace(" PM","").Replace(" ","_")
    $passFail   = ""

#endregion: Config

#region: computer loop

    foreach($computer in $list){
            #region: csv loop
                foreach ($line in $csv){
                    $GoValuesArray = @($line.GoValuesArray.Split(";"))
                    foreach ($value in $GoValuesArray){
                        $appName  = $line.Name
                        $class    = $value.Split(".")[0]
                        $property = $value.Split(".")[1]
                        $propVal  = (Get-ProcessMitigation -Name $appName -WarningAction SilentlyContinue).$class.$property
                        
                        foreach ($value in $CheckValue){
                            if($results -eq $value){
                                $passFail = "Pass"
                                break
                            }else{
                                $passFail = "Fail"
                            }
                        }

                        $obj = [PSCustomObject][ordered]@{
                            "Computer"      = $computer
                            "Status"        = $status                          
                            "Vul_ID"        = $line.Vul_ID
                            "Application"   = $line.Name
                            "Class"         = $class
                            "Property"      = $property
                            "Value"         = $propVal
                            "Prop_Val_Test" = $valTest_Status
                        }

                        $results += $obj
                    }
                }

            #endregion: csv loop

            #region: Vul_ID Summary loop

            foreach ($line in $csv){
                $Vul_ID = $line.Vul_ID
                $pvtres = ($results | ? -Property Vul_ID  -EQ $Vul_ID).Prop_Val_Test

                if("FAIL" -in $pvtres){
                    $passFail = "FAIL"
                }elseif ("PASS" -in $pvtres){
                    $passFail = "PASS"
                }

                $obj = [PSCustomObject]@{
                    Computer    = $computer
                    Status      = $status                          
                    Vul_ID      = $line.Vul_ID 
                    Pass_Fail = $passFail 
                }

                $Vul_ID_Test_Results += $obj
            }


        }

#endregion: computer loop



<#
"This is NA prior to v1709 of Windows 10.

This is applicable to unclassified systems, for other systems this is NA.

Run ""Windows PowerShell"" with elevated privileges (run as administrator).

Enter ""Get-ProcessMitigation -Name Acrobat.exe"".
(Get-ProcessMitigation can be run without the -Name parameter to get a list of all application mitigations configured.)

If the following mitigations do not have the listed status which is shown below, this is a finding

DEP:
OverrideDEP: False

ASLR:
ForceRelocateImages: ON

Payload:
OverrideEnableExportAddressFilter: False
OverrideEnableExportAddressFilterPlus: False
OverrideEnableImportAddressFilter: False
OverrideEnableRopStackPivot: False
OverrideEnableRopCallerCheck: False
OverrideEnableRopSimExec: False


The PowerShell command produces a list of mitigations; only those with a required status of are listed here. If the PowerShell command does not produce results, ensure the letter case of the filename within the command syntax matches the letter case of the actual filename on the system."




#>