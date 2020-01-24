param([Parameter(Mandatory=$true)][string] $hostname,[Parameter(Mandatory=$true)][string] $path)


#Do the thing
Invoke-Command -ComputerName $hostname ClamAV.ps1 -ArgumentList $path