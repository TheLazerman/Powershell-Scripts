Param([Parameter(Mandatory=$true)][string]$hostname, [Parameter(Mandatory=$true)][string]$username )
psexec \\$hostname net localgroup Administrators "simfoods.com\$username" /add
exit 0
