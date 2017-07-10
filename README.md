# Powershell-Scripts
Various Handy Dandy Powershell Scripts for Making Life Easier


You may need to preform a few extra setup steps before several of these scripts will run correctly. They are easy steps however and do not take very long to complete. 

The RSAT (Remote Server Administration Toolkit) Active Directory feature will need to be installed and enabled. The RSAT can be downloaded Here(https://www.microsoft.com/en-us/download/confirmation.aspx?id=45520) for Windows 10 and Here(https://www.microsoft.com/en-us/download/confirmation.aspx?id=7887) for Windows 7. Once it is installed you may need to ensure it is enabled in the OS. Open up the start menu and search for  "Turn Windows Features On or Off" (If you don't already have this installed, I recommend you check it out, lots of cool stuff)

Next you will need to ensure powershell can run on your system. In a powershell window, run the command "set-executionpolicy RemoteSigned"
Finally, you will need to "Dot Source" the script. To do this, open a powershell window and navigate to where the script is stored and enter a period or "dot" in front of the script name. ". .\Get-LockedOutLocation.ps1"

Now you will be able to run the script by simply typing the name of the script without the ".\" in front of it and without the ".ps1" on the end. (Powershell will auto-add these if you use tab to complete the name).
Running the script should match the image below, replacing "gabriel.coones" with the name of the user you would like to audit. 
