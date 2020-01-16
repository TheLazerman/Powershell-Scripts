# Powershell-Scripts
Various Handy Dandy Powershell Scripts for Making Life Easier


You may need to preform a few extra setup steps before several of these scripts will run correctly. They are easy steps however and do not take very long to complete. 

First, ensure powershell can run on your system. In a powershell window, run the command "set-executionpolicy RemoteSigned"

You will also need the RSAT (Remote Server Administration Toolkit) installed if you do not have it already.
In the latest versions of Windows 10, RSAT is easiest to enable through powershell. Open an elevated powershell window and run the following command: <code> Get-WindowsCapability -Online -Name *RSAT* | Add-WindowsCapability -Online </code>
This may take a few minutes to run, but once complete you will have all of the RSAT tools installed and ready to go. 

For older versions of Windows 10: (update your danged computer)
The RSAT can be downloaded Here(https://www.microsoft.com/en-us/download/confirmation.aspx?id=45520)
Once it is installed you may need to ensure it is enabled in the OS. Open up the start menu and search for <i> "Turn Windows Features On or Off" </i>

Several of these scripts will need to be dot-sourced to run correctly. This basically brings the script into your current scope. <a href="https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-7#script-scope-and-dot-sourcing">See the docs here.</a> 
To do this, open a powershell window and navigate to where the script is stored and enter a period or "dot" in front of the script name. ". .\Get-LockedOutLocation.ps1"
