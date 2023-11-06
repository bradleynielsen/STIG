<#
----------------------
How to run the script:
----------------------
1. Right click on "run.ps1"
2. Click Run with PowerShell

---------------------------
How to configure the files
---------------------------
You will need to add information from the SAP to ensure that information from the testing files agrees with the SAP 
and the lookup tables used in the script. 
Do the following:

1.  Copy test files in the respective folders

2.  Review the "config" folder:
        • assessmentmethods.csv (This is the list of Hosts and test battery from the SAP [Assessment Methods] tab)
        • saplookuptable.csv (This is used to tie the SAP Test Battery list to the files's STIG ID.)

3.  Configure the assessmentmethods.csv 

        a) Copy the SAP [Assessment Methods] columns
            • Test Target - Hostname
            • IP Address
            • Test Battery

        b) Paste this into the file called "assessmentmethods.csv"

4.  Configure the saplookuptable.csv

        a) ensure that all Test Battery lines are paired with the correct STIG IDs from CKL and XCCDF
        
        b) If the list is not complete do the following:

            i) Run this script to produce a list of unique IDs in the output folder. There will be two files:
                • UniqueSTIGIDs.txt
                • UniqueTestBatteryList.txt

            ii) Copy the UniqueSTIGIDs values from "UniqueSTIGIDs.txt" into "saplookuptable.csv" 
                 - copy UniqueSTIGIDs.txt 
                 - open saplookuptable.csv
                 - paste into  ["stigid"] column

            iii) Copy the testBattery from "UniqueTestBatteryList.txt" to the "saplookuptable.csv" "sapTestBattery" column
                 - copy UniqueTestBatteryList.txt 
                 - open saplookuptable.csv
                 - paste into  ["sapTestBattery"] column


5.  Once all of the configuration is complete you can run the script. 

6.  Open the "output" folder to view the output from the script
        a) "completenessTest.csv" 
                will give you insight on:
                • Missing files for each test battery
                • Duplicate files for each test battery
                • Inconsistent STIG IDs between the SAP <> Filename <> STIG data
                • Inconsistent STIG versions between the STIGS


        b) "fileValues.csv" 
            Details from inside the CKL and XCCDF files

        c) UniqueSTIGIDs.txt
            Produced from the STIG files

        d) UniqueTestBatteryList.txt
            Produced from the "saplookuptable.csv"

