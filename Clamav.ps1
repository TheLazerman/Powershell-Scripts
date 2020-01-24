#Parameters from EPO_ClamAv.ps1
Param([Parameter()][string]$scanPath)


#if ClamScan is running, don't do anything
if (Get-Process -ProcessName "*ClamScan*"){return 0}

#Update ClamAV Definitions
Start-Process "C:\clamav\freshclam.exe" -ArgumentList "--quiet --log=C:\clamav\Log\update.log" -Wait

#Scan the PC
Start-Process "C:\clamav\clamscan.exe" -ArgumentList "--quiet -r $scanPath --log=C:\clamav\log\$env:COMPUTERNAME.log" -Wait

#Access is denied.
Copy-Item "C:\clamav\log\$env:COMPUTERNAME.log"  -Destination "\\vm-pdq\c$\PDQEventlogs\clam\"