# Powershell-Scripts
### Various Handy Dandy Powershell Scripts for Making Life Easier.


You may need to preform a few extra setup steps before several of these scripts will run correctly. They are easy steps however and do not take very long to complete. 

1. Ensure powershell has the correct execution policy set to run these scripts. 
	1. In a powershell window, run the command "set-executionpolicy RemoteSigned"
2. Install the latest version of RSAT (Remote Server Administration Toolkit) if you do not have it already.
	1. Open a powershell window with admin privileges and run the following command:  
     ``Get-WindowsCapability -Online -Name *RSAT* | Add-WindowsCapability -Online``  
	   This may take a few minutes to run, but once complete you will have all of the RSAT tools installed and ready to go. 
	2. For older versions of Windows 10: (Update your computer)
		1. Download RSAT from [Here](https://www.microsoft.com/en-us/download/confirmation.aspx?id=45520)
		2. Once installed, you may need to enable it in the OS. Open up the start menu and search for <i>"Turn Windows Features On or Off"</i> and check the RSAT box.  

### Several of these scripts will need to be dot-sourced to run correctly.
[See the docs here.](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-7#script-scope-and-dot-sourcing)
This just brings the script into the current scope. (Think importing a module in python. ~ish)   
To do this, open a powershell window and navigate to where the script is stored and enter a period or "dot" in front of the script name. ". .Get-LockedOutLocation.ps1"
