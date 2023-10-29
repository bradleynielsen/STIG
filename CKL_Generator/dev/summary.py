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
                                                                        print("Updating "+xccdf_host_name+" CKL "+cklVulnID+" with data from Summary CSV", end = '')
                                                                        trackerUsed = False
                                                                        count += 1
                                                                        element_VULN.find('STATUS').text = "NotAFinding"                                                                    
                                                                        trackercsv = csv.DictReader(open(trackercsvpath))                                
                                                                        for row in trackercsv:
                                                                            print("tracker ID: " + trackerVul_ID +"CKL ID" + cklVulnID)
                                                                                
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
                                                                            print("Updating "+xccdf_host_name+" CKL "+cklVulnID+" with data from Summary CSV", end = '')
                                                                        

                                                    except:
                                                        #summarycsv failed to load
                                                        
                                                        continue