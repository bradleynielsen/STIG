import xml.etree.ElementTree as ET
import shutil
import time
import csv
import os
stigSummaryCsvPath = ".\\STIG_Summary.csv"
summarycsvpath     = ".\\summary.csv"
trackercsvpath     = ".\\tracker.csv"
templateCKLdir     = ".\\templateCKL"
ckl_resultsdir     = ".\ckl_results"
xccdfdir           = ".\\xccdf"
tempdir            = ".\\temp"
startTimer         = time.perf_counter()
csvCreated         = False
count              = 0
notreviewed        = 0
for root, dirs, files in os.walk(xccdfdir):
    for xccdfFilename in files:        
        #parse the xccdf XML data        
        xccdftree     = ET.parse('.\\xccdf\\'+xccdfFilename)        
        xccdftreeroot = xccdftree.getroot()
        testResult    = xccdftreeroot.find("{http://checklists.nist.gov/xccdf/1.2}TestResult")
        targetFacts   = testResult.find("{http://checklists.nist.gov/xccdf/1.2}target-facts")        
        #get target host information 
        for factElement in targetFacts:
            name = factElement.attrib.get("name")
            if (name == "urn:scap:fact:asset:identifier:host_name"):    #host_name
                xccdf_host_name = factElement.text
            if (name == "urn:scap:fact:asset:identifier:ipv4"):         #ipv4
                xccdf_ipv4 = factElement.text
            if (name == "urn:scap:fact:asset:identifier:mac"):          #mac
                xccdf_mac = factElement.text
            if (name == "urn:scap:fact:asset:identifier:fqdn"):         #fqdn
                xccdf_fqdn = factElement.text
        #create the ckl file for the xccdf host
        for root, dirs, files in os.walk(templateCKLdir):
            for filename in files:        
                source = os.path.join( os.path.abspath(root), filename )        
                cklfilename = xccdf_host_name+".ckl"
                destination = os.path.join(tempdir,cklfilename)
                shutil.copy(source,destination)
                time.sleep(1)
                print("Generating CKL file for "+xccdf_host_name)                
        #process the CKL file                
        for root, dirs, filenames in os.walk(tempdir):            
            for cklFilename in filenames:                
                base, extension = os.path.splitext(cklFilename)                    
                if (base == xccdf_host_name):                           #match the ckl file to xccdf hostname                    
                    #Parse the ckl file   
                    tree              = ET.parse(tempdir+"\\"+cklFilename)
                    element_checklist = tree.getroot()
                    element_asset     = element_checklist[0]
                    element_stigs     = element_checklist[1]
                    element_iStig     = element_stigs[0]                    
                    #find the Asset information elements
                    element_HOST_NAME = element_asset.find("HOST_NAME")
                    element_HOST_IP   = element_asset.find("HOST_IP")
                    element_HOST_MAC  = element_asset.find("HOST_MAC")
                    element_HOST_FQDN = element_asset.find("HOST_FQDN")
                    #set Asset information
                    element_HOST_NAME.text = xccdf_host_name
                    element_HOST_IP.text   = xccdf_ipv4
                    element_HOST_MAC.text  = xccdf_mac
                    element_HOST_FQDN.text = xccdf_fqdn                    
                    #Process the VULN elements
                    for iStig_child in element_iStig:       
                        #select only "VULN" elements
                        if iStig_child.tag == 'VULN':
                            element_VULN = iStig_child
                            #init the ID vars
                            cklVulnID      = ""
                            cklRuleID      = ""                            
                            xccdfValueUsed = False                            
                            #if the STIG VULN_ATTRIBUTE element matches either "Vuln_Num" or "Rule_ID", get the ID text                            
                            for element_stigdata in element_VULN:                                                                
                                if len(list(element_stigdata)) > 0:
                                    xccdfValueUsed = False                      #set variable to track if xccdf is used for this VULN
                                    vulnAttributeTag = element_stigdata[0].text #get the attribute value
                                    if vulnAttributeTag == 'Vuln_Num':     
                                        cklVulnID = element_stigdata[1].text    #get the CKL Vul ID                                                                          
                                    if vulnAttributeTag == 'Rule_ID':                                        
                                        cklRuleID      = element_stigdata[1].text   #get the CKL Rule ID                                        
                                        #When both IDs are found in the CKL VULN...
                                        if (cklVulnID !="" and cklRuleID != ""):
                                            #init the vars:
                                            cklStatus               = ""
                                            finding_details         = ""
                                            trackerComments         = ""
                                            trackerSet_Status       = ""                                     
                                            trackerFinding_Details  = ""                                            
                                            #First try to process the SCAP results                                            
                                            for ruleResult in testResult.iter("{http://checklists.nist.gov/xccdf/1.2}rule-result"): #Loop over the SCAP results
                                                idref = (ruleResult.attrib.get("idref")).replace("xccdf_mil.disa.stig_rule_","")    #get the SCAP rule ID                                                                               
                                                #match the idref to the CKL rule ID
                                                if (idref == cklRuleID):                                    
                                                    xccdfValueUsed = True
                                                    #get the SCAP test result                                                    
                                                    for resultchild in ruleResult:
                                                        if ( resultchild.tag == "{http://checklists.nist.gov/xccdf/1.2}result" ):                                                            
                                                            resultValue = resultchild.text
                                                            if (resultValue == "pass"):
                                                                cklStatus = "NotAFinding"
                                                                #print(cklStatus)
                                                            if (resultValue == "fail"):
                                                                cklStatus = "Open"
                                                                try:
                                                                    trackercsv = csv.DictReader(open(trackercsvpath))
                                                                    for row in trackercsv:
                                                                        trackerVul_ID = (row["Vul_ID"])
                                                                        if (trackerVul_ID == cklVulnID):
                                                                            #Set the Finding details and comments from the tracker csv
                                                                            trackerFinding_Details = "\n Additional Info: \n"+(row["Finding_Details"])                                                                        
                                                                            trackerComments        = (row["Comments"])                                                                    
                                                                except:
                                                                    pass                                                                
                                                            #print("Updating "+xccdf_host_name+" CKL "+cklVulnID+" with data from XCCDF", end = '')
                                                            trackerUsed = False
                                                            count += 1
                                                            #build finding details text
                                                            toolName = (testResult.attrib).get("test-system")
                                                            testTime = (testResult.attrib).get("end-time")
                                                            try:                                                                
                                                                finding_details = "Tool: "+toolName+"\n"+"Time: "+testTime+"\n"+"Result: "+resultValue + trackerFinding_Details
                                                                trackerUsed = True 
                                                            except:
                                                                finding_details = "Tool: "+toolName+"\n"+"Time: "+testTime+"\n"+"Result: "+resultValue
                                                                trackerComments = ""                                                            
                                                            #write the changes to the CKL VULN element                                                            
                                                            element_VULN.find('STATUS').text                 = cklStatus                                                
                                                            element_VULN.find('FINDING_DETAILS').text        = finding_details
                                                            element_VULN.find('COMMENTS').text               = trackerComments                                                                                                                   
                                                            break                                                        
                                            #XCCDF has no results, try the custom script summary csv
                                            if (xccdfValueUsed == False):                                                
                                                try:
                                                    summarycsv = csv.DictReader(open(summarycsvpath))
                                                    summaryValueUsed = False
                                                    #loop over the summary
                                                    for row in summarycsv:                                                        
                                                        if (row['Computer         ']) == xccdf_host_name:
                                                            try:
                                                                if row[cklVulnID] == "Pass":                                                                
                                                                    #print("Updating "+xccdf_host_name+" CKL "+cklVulnID+" with data from Summary CSV", end = '')
                                                                    trackerUsed = False
                                                                    count += 1
                                                                    element_VULN.find('STATUS').text = "NotAFinding"                                                                    
                                                                    trackercsv = csv.DictReader(open(trackercsvpath))                                
                                                                    for row in trackercsv:
                                                                        # get the finding details and comments value from the tracker csv
                                                                        trackerVul_ID          = (row["Vul_ID"])
                                                                        trackerFinding_Details = (row["Finding_Details"])
                                                                        trackerComments        = (row["Comments"])
                                                                        trackerInitial_Status  = (row["Initial_Status"])
                                                                        trackerSet_Status      = (row["Set_Status"])                                                                    
                                                                        if trackerVul_ID != cklVulnID:
                                                                            continue
                                                                        if trackerVul_ID == cklVulnID:                                                                                                                                               
                                                                            element_VULN.find('FINDING_DETAILS').text        = trackerFinding_Details
                                                                            element_VULN.find('COMMENTS').text               = trackerComments
                                                                            trackerUsed = True                                                                                                                                           
                                                                        summaryValueUsed = True
                                                                if row[cklVulnID] == "Fail":
                                                                    #print("Updating "+xccdf_host_name+" CKL "+cklVulnID+" with data from Summary CSV", end = '')
                                                                    trackerUsed = False
                                                                    element_VULN.find('STATUS').text = "Open"
                                                                    #if the summary status is fail, get the value from the tracker csv
                                                                    trackercsv = csv.DictReader(open(trackercsvpath))                                
                                                                    for row in trackercsv:
                                                                        trackerVul_ID          = (row["Vul_ID"])
                                                                        trackerFinding_Details = (row["Finding_Details"])
                                                                        trackerComments        = (row["Comments"])
                                                                        trackerInitial_Status  = (row["Initial_Status"])
                                                                        trackerSet_Status      = (row["Set_Status"])
                                                                        if trackerVul_ID != cklVulnID:
                                                                            continue
                                                                        if trackerVul_ID == cklVulnID:                                                                        
                                                                            element_VULN.find('STATUS').text                 = trackerSet_Status                                                
                                                                            element_VULN.find('FINDING_DETAILS').text        = trackerFinding_Details
                                                                            element_VULN.find('COMMENTS').text               = trackerComments
                                                                            trackerUsed = True                                                                        
                                                            except:
                                                                #nothing found in summary csv
                                                                continue
                                                except:
                                                    #summarycsv failed to load
                                                    continue
                        else:
                            #iStig child element is not 'VULN'
                            continue
                    #Summarizing results    
                    hostResultsDict = {"Hostname":xccdf_host_name}
                    for vuln in element_iStig:
                        for stigdata in vuln:
                            for attribute in stigdata:                                
                                if(attribute.text == "Vuln_Num"):                                    
                                    statusCheck = vuln.find("STATUS").text                                    
                                    if (statusCheck == ""):    #verify no status left unset:
                                        vuln.find("STATUS").text = "Not_Reviewed"                                    
                                    status = vuln.find("STATUS").text
                                    vulid  = stigdata.find("ATTRIBUTE_DATA").text
                                    vulnDict = {vulid:status}                                                      
                                    hostResultsDict.update(vulnDict) #update the host Vuln_Num dict with vuln and status                     
                    if (csvCreated == False):
                        with open(stigSummaryCsvPath, 'w', newline='\n') as csvfile:
                            writer = csv.DictWriter(csvfile, fieldnames=hostResultsDict.keys())
                            writer .writeheader()                           
                            writer.writerow(hostResultsDict)
                            csvCreated = True                            
                    else:
                        #writing CSV to file            
                        with open(stigSummaryCsvPath, 'a', newline='\n') as csvfile:
                            writer = csv.DictWriter(csvfile, fieldnames=hostResultsDict.keys())                            
                            writer.writerow(hostResultsDict)
                    #writing new CKL to file            
                    filepath = os.path.join(ckl_resultsdir,cklfilename)
                    tree.write(filepath,xml_declaration=True,encoding='utf-8',default_namespace=None,method="xml")                    
print("Removing Temp Files")        
for root, dirs, files  in os.walk(tempdir):
    for file in files:        
        os.remove(tempdir+'\\'+file)        
endTimer = time.perf_counter()
seconds = round((endTimer-startTimer))
print("Processed "+str(count)+" Vul IDs in "+str(seconds)+" seconds")
