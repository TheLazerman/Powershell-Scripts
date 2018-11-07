param([Parameter(Mandatory=$true)][string] $hostname)
copy-item \\simfoods.com\deploymentshare$\Scripts\Customizations\StartMenu\DefaultLayout.xml \\$hostname\c'$'\Windows\Temp\DefaultLayout.xml
copy-item \\simfoods.com\\deploymentshare$\Scripts\Customizations\StartMenu\ApplyLayout.ps1 \\$hostname\c'$'\Windows\Temp\ApplyLayout.ps1
psexec \\$hostname cmd /c powershell 'set-executionpolicy remotesigned' 
psexec \\$hostname cmd /c powershell C:\Windows\Temp\ApplyLayout.ps1
psexec \\$hostname cmd /c shutdown -r -f -t 0