Run the run-moduels from elevated powershell.

.ps1 files in the .\modules folder represent each Vul ID that is being scanned.
Moving the modules to another directory will stop that Vul ID from being scanned.

You can run the script against an OU, or a static list. 
Define the AD OU searchbase in the script by adding the DN of the OU to the '$searchbase' variable.

Summary Results will show which Vul ID failed.
'test_results' will contain details of which computer failed which Vul ID.
