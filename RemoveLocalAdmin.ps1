Param([Parameter(Mandatory=$true)][string]$hostname, [Parameter(Mandatory=$true)][string]$username )
psexec \\$hostname net localgroup Administrators "simfoods.com\$username" /delete
exit 0
