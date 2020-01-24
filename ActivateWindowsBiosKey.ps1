$computer = gc env:computername
$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $computer
$key = $service.OA3xOriginalProductKey
cscript.exe //B "%windir%\system32\slmgr.vbs" /ipk $key
cscript.exe //B "%windir%\system32\slmgr.vbs" /ato
$service.RefreshLicenseStatus()